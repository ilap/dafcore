// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
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
 */

namespace Daf.Core {

    public class ModelPresenter : AbstractModelHolder, IModelPresenter, IAspectTrigger {

        private ModelRegistrar registrar;
        private AspectTrigger trigger;

        public IValueModel dirty { get; construct set; }
        public IValueModel auto_commit { get; construct set; }

        construct {
            dirty = new ValueHolder ();
            //auto_commit = new ValueHolder (auto_commit);
            registrar = new ModelRegistrar ();
            //
            trigger = new AspectTrigger ();
        }

        public ModelPresenter (Object model, bool auto_commit = false) {
            base (model, null);
        }

        protected override void setup_notify () {
            //.changed ("Setup notify");
            this.value_model.notify[IValueModel.PROP_NAME].connect (on_model_change);
            this.value_model.notify_property (IValueModel.PROP_NAME);
        }

        public void commit () {
            debug ("Commit's called\n");
            trigger.set_val (AspectTrigger.COMMIT);
        }

        public void discard () {
            debug ("Discard's called\n");
            trigger.set_val (AspectTrigger.DISCARD);
        }

        public IValueModel? get_value_model (string path) {

           /* IValueModel value_model = registrar.get_value_model (path);

            if (value_model == null && this.value_model.get_val () != null) {
                debug ("Before Wrap aspect: %s", path);
                var aspect_adapter =  (IValueModel) compute_aspect_model (path);
                debug ("Wrap aspect: %s\n", path);
                value_model = new BufferedValueHolder.with_trigger (aspect_adapter, trigger);
                debug ("Wrapped aspect: %s", path);
                value_model.notify["dirty"].connect (on_dirty_change);
                registrar.add_value_model (path, value_model);
            }
            return value_model;*/
            IValueModel model = registrar.get_value_model (path);
            debug ("Is Value model null? : %s need to register one: %s", (model == null).to_string (), path);

            if (model == null /*&& this.value_model.get_val () != null*/) {

                debug ("Before Wrap aspect: %s", path);
                var aspect_adapter =  (IValueModel) compute_aspect_model (path);
                debug ("Wrap aspect: %s\n", path);
                model = new BufferedValueHolder.with_trigger (aspect_adapter, trigger);
                debug ("Wrapped aspect: %s", path);
                model.notify["dirty"].connect (on_dirty_change);
                registrar.add_value_model (path, model);
            }
            return model;

        }

        private void on_dirty_change (Object source, ParamSpec param_spec) {
            bool d = ((BufferedValueHolder) source).dirty;
            debug ("on_dirty_change: %s\n", d.to_string ());
            this.dirty.set_val (d);
        }

        /*
         * We need to rebind all the registered ValueModels to the new Object.
         */
        protected override void on_model_change (Object sender, ParamSpec param_spec) {
            debug ("On Model change");
            debug ("print OBJECT %s\n", sender.get_type (). name ());

            if (sender == value_model) {
                var map = registrar.get_all_models ();

                foreach (var entry in map.entries) {

                    BufferedValueHolder ivm = entry.value as BufferedValueHolder;

                    /* if (ivm == null) {
                        debug ("NULL\n");
                    } else {
                       debug ("NOT NULL\n");
                    }*/
                    // debug ("print %s\n", ivm.value_model.get_type().name());
                    /// FIXME:
                    // ORIG: IModelAdapter ima = ivm.value_model as IModelAdapter;
                    IModelHolder ima = ivm.subject as IModelHolder;

                    //.changed ("Value model get val is null: %s", (value_model.get_val () == null).to_string ());
                    var object = value_model.get_val ();
                    if (object != null) {
                        ima.set_model ((Object) object);
                    } else {
                        ima.set_model (null);
                    }
                }
                discard ();
                // debug ("After MODEL");
            }

            //value_model.notify_property (IValueModel.PROP_NAME);
            // all the Object's property to registered value holders.
            // the existing
            debug ("Channel has.changed....%s", param_spec.name);
        }

        /**
         * Currently we just support one depth in an object's graph.
         * Valid path are:
         * "property_name"
         * "object_name.property_name"
         *
         */
        private Object? compute_path (ref string path) {

            debug ("BBBBBBB");
            Object object;

            var a = value_model.get_val ();
            if (a != null) {
                object = (Object) value_model.get_val ();
            } else {
                return null;
            }
            /**
             * TODO: support depth.
             */
            if (path.contains (".")) {

                int last_dot = path.last_index_of_char ('.', 0);
                var obj_name = path.substring (0, last_dot);

                path = path.substring (last_dot+1);

                Value obj_value = Value (typeof (Object));

                object.get_property (obj_name, ref obj_value);
                // FIXME: assert when it's not an object
                object = obj_value.get_object ();

            }
            return object;
        }

        private IValueModel compute_aspect_model (string path) {
            string property_path = path;
            var object = compute_path (ref property_path);
            var aspect_adapter = new AspectAdapter (object, property_path);

            return aspect_adapter;
        }

    }
}

