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
     * TODO: Impelents to not emitt event if the Values (old and new) are equal and make it
     * configurable on run time.
     * e.g. public bool always_emitt = true; it's default now /wo any modification
     * ...
     * if (always_emitt == false) { check old and new value;
     */
    public abstract class AbstractValueHolder : Object, IValueModel {
        [CCode(notify = false)]
        public bool locked { get; set; default = false; }

        /**
         * The restriciton on notify that the model_value cannot be retrieved through ParamSpec but
         * call directly with the sender's get_val () method, see detail below.:
         *
         * on_value_changed (Object sender, ParamSpec param_spec) {
         *    var val = (sender as IValueModel).get_val (); // instead of param_spec.
         *
         **/
         private Value _model_value;
         protected Value model_value {
            protected get {
                return _model_value;
            }
            protected set {
                _model_value = value;
                model_state = _model_value;
             }
        }

        // The nullable Value property (Value?) cannot be notified,
        // therefore a helper field (model_state) is used for holding nullable Value.
        private Value? model_state = null;

        protected bool observe_domain_changes = false;

        /** FIXME: It's hard to implement comparation as GValues are not easibly comparable.
         * private bool always_emitt;
         * we could implement some helper method like below:
         * switch (type.name ()) {
         *     case "gint": return (int) old_value == (int) new_value;
          *
         **/
        public virtual Value? get_val () {
            return model_state;
        }

        public virtual void set_val (Value? new_value) {
            lock (model_state) {
                do_set_val (ref model_state, new_value);
            }
        }
    }
}