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

namespace Daf.Core {

    public abstract class AbstractModelHolder : AbstractValueHolder {

        public IValueModel? value_model { get; construct set; }

        public string property_name { get; construct set; }
        protected string canonical_property_name;

        /**
         * The property name cannot be null.
         **/
        public AbstractModelHolder (Object? model, string? property_name = null) {
            //this.notify_on_model_change = notify_on_model_change;

            if (property_name == null) {
                this.property_name = IValueModel.PROP_NAME;
            } else {
                this.property_name = property_name;
            }

            this.canonical_property_name = /_/.replace (this.property_name, -1, 0, "-");

            if (model is IValueModel) {
                debug ("It is ValueModel");
                // TODO: Throw error if the model Value (domain model) is not an Object.
                Value? model_value = (model as IValueModel).get_val ();

                if (model_value != null) {
                    // Dynamic type checking causing SIGSEGV.
                    // e.g. assert (model_value is Object);
                    assert (model_value.holds (typeof (Object)));
                } else {
                    // TODO check whether it's holding Object or not...
                }
                this.value_model = model as IValueModel;


            } else {
                this.value_model = new ValueHolder (model);
            }
            
            setup_notify ();
        }

        protected abstract void setup_notify ();
        protected abstract void on_model_change (Object source, ParamSpec param_spec);
    }
}


