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

    /**
     * AspectAdapter adapt the IValueModel for an Object's property.
     * Therefore the setter/getter methods of an AspectAdapter changes/retrieves
     * the Object's property.
     *
     *    Setter: notifies the underlayed ValueModel's property.
     *  There are two types of events monitored:
     *    1. monitor the change of the underlaying domain model using model_changed event and
     *    2. monitor the underlaying domain model's associated property change using
     *        IValueModel's norify signal of the property .
     *
     * Keep in mind that domain's property cannot be Value? as it won't be set up
     * by  GLibs install_property due the fature/bug of Vala.
     *
     */
    public class AspectAdapter : AbstractValueHolder, IModelHolder {
        private ulong value_changed_id = 0L;
        private ulong domain_changed_id = 0L;

        private Type? model_type;

        public IValueModel? value_model { public get; protected set; }

        private bool observe_domain_changes = false;

        private string _property_name;
        public string property_name {
                get {
                return _property_name;
            } private set {
                if (value != null) {
                    _property_name = /_/.replace (value, -1, 0, "-");
                }
            }
        }

      public AspectAdapter (Object? value_model, string property_name, bool observe_domain_changes = false) {

            this.property_name = property_name;
            this.observe_domain_changes = observe_domain_changes;

            if (value_model is IValueModel) {
                this.value_model =  value_model as IValueModel;
            } else {
                this.value_model = new ValueHolder ();
                this.set_model (value_model);
            }

            // Setup the signals
            value_changed_id = this.notify[PROP_NAME].connect (value_changed);

            // Initially connect domain model's signal...
            do_setup_signals (get_model (), true);

            this.value_model.before_value_changed.connect (before_model_changed);
            this.value_model.notify[PROP_NAME].connect (model_changed);
        }

        /**
         * If the underlying domain model is empty then it returns null.
         **/
        public override Value? get_val () {

            var model = get_model ();
            Value? result = null;

               if (model != null) {
                   //message ("MODEL IS NOT NULL");
                   if (model is IValueModel) {
                    result = (model as IValueModel).get_val ();
                } else {
                    result = read_property ((Object) model, property_name);
                }
            }
            return result;
        }

        /**
         * It silently ingores any changes if the underlying domain model is null.
         **/
        public override void set_val (Value? new_value) {
            var model = get_model ();
            if (model != null) {

                if (model is IValueModel) {
                    (model as IValueModel).set_val (new_value);
                } else {
                    write_property (model, property_name, new_value);
                }
            } else {
                // It's just a dummy call for emitting the notify if the property has changed from not null.
                base.set_val (null);
            }
        }

        /**
         * Model's setter/getter will return the underlayed domain object or null and
         * will notify the listeners trhough the property.changed event.
         **/
        public Object? get_model () {
            return get_object_model (value_model.get_val ());
        }

        private Object? get_object_model (Value? model) {
            Object? result = null;
            if (model != null) {
                result = (Object?) model;
            }
            return result;
        }

        private Value? set_object_model (Object? model) {
            Value? result = null;
            if (model != null) {
                Value v = Value (typeof (Object));
                v = model;
                result = (Value) v;
            }
            return result;
        }

        public void set_model (Object? new_model) {
               value_model.set_val (set_object_model (new_model));
        }


        public void before_model_changed (Value? old_model) {
            do_setup_signals (get_object_model (old_model), false);
        }

        public void value_changed (Object sender, ParamSpec param_spec) {
            if (observe_domain_changes && value_changed_id != 0L) {
                // Notify the listeners if the underlaying domain object's
                // property has.changed.
                GLib.SignalHandler.block ( (void*) this, value_changed_id);
                base.set_val (get_val ());
                   GLib.SignalHandler.unblock ( (void*) this, value_changed_id);
              }
        }

        public void model_changed (Object sender, ParamSpec param_spec) {
            do_set_model (get_object_model (value_model.get_val ()));
        }

        public void domain_property_changed (Object sender, ParamSpec param_spec) {
            notify_property (PROP_NAME);
        }


        private void do_set_model (Object? new_model) {

            var old_model = get_model ();

            if (old_model != null && new_model != null) {
                assert (old_model.get_type () == new_model.get_type ());
            }

            if (new_model != null) {
                assert (check_property_compatibility (new_model, property_name));
                do_setup_signals (new_model, true);
            }
        }

        private void do_setup_signals (Object? model, bool connect) {
            if (model != null) {
                if (connect) {
                    model.notify[property_name].connect (domain_property_changed);
                } else {
                    model.notify[property_name].disconnect (domain_property_changed);
                }
            }
        }

        private Value? read_property (Object? object, string property_name) {
            if (object == null) {
              //  if (model_type != null && !model_type.is_object ()) {
              //      return "";
                 //} else {
                     return null;
                 //}
            }

            ParamSpec? param_spec = object.get_class ().find_property (property_name);
            assert (param_spec != null);

            Value model_value = Value (param_spec.value_type);
            if (model_type == null) {
                debug ("model_type is set to: %s", param_spec.value_type.name ());
                model_type = param_spec.value_type;
            }

            object.get_property (property_name, ref model_value);
           // FIXME:
            if (model_value.strdup_contents () == "NULL") {
                return null;
            } else {
                return model_value;
            }
        }

        private void write_property (Object model, string property_name, Value? new_value) {
            // FIXME: Delete debug ("Write property %s", (new_value == null).to_string ());
            if (new_value == null) {

                ParamSpec? param_spec = model.get_class ().find_property (property_name);
                assert (param_spec != null);

                // debug ("TYPE %s", param_spec.name);
                if (param_spec.value_type != typeof (Value)) {
                    Value val = ""; // empty string.
                    Value model_value = Value (param_spec.value_type);
                    if (Value.type_transformable (val.type (), param_spec.value_type)) {
                        val.transform (ref model_value);
                    }
                    model.set_property (property_name, model_value);
                } else {
                    // It's a Value type...
                    model.set_property (property_name, new_value);
                }

            } else {
                model.set_property (property_name, new_value);
            }
        }

        private bool check_property_compatibility (Object domain_model, string property_name) {
            ParamSpec? param_spec = domain_model.get_class ().find_property (property_name);
            return param_spec != null;
        }
    }
}
