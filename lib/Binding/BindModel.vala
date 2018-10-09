/**
 * Copyright (c) 2012 Pal Dorogi <pal.dorogi@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 **/

using Daf.Core;

namespace Daf.Core.Binding {

    /*
     * Initially just a two way binding /w automatic notify
     * property change at bind time has been implemented.
     *
     * The following scenarios should be implemented:
     * bind ().to (): (default) two way binding, automated notify at bind time.
     * bind_one_way ().to (): one way, automated notify at bind time.
     * bind ().without_notify_to (): 2way, notify disabled at bind time.
     * bind_one_way ().without_notify_to (): 1way,notify disabled at bind time.
     */
    public class BindModel : AbstractAcyclicGraph, IBindModel, IBindTo, IBindFrom {

        public IValueModel model { get; construct set; }
        public IBindModelService service { get; construct set; }

        public bool model_locked = false;

        public BindModel (string name, IBindModelService service, IValueModel model) {
            Object (service: service, model:model);
            //this.service = service;
            //this.model = model;
            this.name = name;
        }

        public void from (Object subject, string? property_name = null) {
            var bind_model = service.get_bind_model (subject, property_name);

            if (bind_model != null) {
                this.unbind (bind_model, false);
            }
        }

        public void to (Object subject, string? property_name = null) {
            var bind_model = service.get_or_create_bind_model (subject, property_name);

            assert (bind_model != null);
            this.unbind (bind_model, false);

            this.bind (bind_model, false);
        }

        public void bind (IBindModel bind_target, bool locked = false) {

            model.freeze_notify ();
            if (!locked) {

                // Prevent the cyclical reference...
                this.add_edge (bind_target as IDirectedAcyclicGraph);
                try {
                    this.resolve (bind_target as IDirectedAcyclicGraph);
                } catch (DependencyGraphError error) {
                    debug ("%s", error.message);
                    return;
                }

                bind_target.bind (this, true);
                model.notify_property (IValueModel.PROP_NAME);
            }

            model.notify[IValueModel.PROP_NAME].connect (bind_target.on_model_notify);

            model.thaw_notify ();
        }

        public void unbind (IBindModel bind_target, bool locked = false) {

            model.freeze_notify ();
            if (!locked) {
                bind_target.unbind (this, true);
            }

            bind_target.model.notify[IValueModel.PROP_NAME].disconnect (on_model_notify);

            model.thaw_notify ();
        }

        public void on_model_notify (Object sender, ParamSpec param_spec) {
            debug ("on_model_notify: %s", sender.get_class ().get_type ().name ());
            var value_model = sender as IValueModel;

            if (model.locked) {
                model.locked = false;
                return;
            }

            value_model.locked = true;
               model.set_val (value_model.get_val ());
        }
    }
}