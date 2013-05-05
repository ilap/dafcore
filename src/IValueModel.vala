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

    public interface IValueModel : Object {
        // FIXME: It's temporary added until the Binding's
        // class refactored to some better solution like using
        // SignalHandler's block/unblock see below
        //
        //  GLib.SignalHandler.block ( (void*) this, on.changed_id);
        //    s = (sender as Bind).s;
        //    GLib.SignalHandler.unblock ( (void*) this, on.changed_id);
        public abstract bool locked { get; set; default = false; }

        // The ValueModel using properties instead of signal due the
        // Bindings are bound by properties.
        public const string PROP_NAME = "model-value";

        protected abstract Value model_value { protected get; protected set ;}

        public abstract Value? get_val ();
        public abstract void set_val (Value? new_value);

        public abstract signal void before_value_changed (Value? old_value);

        public virtual void do_set_val (ref Value? model_state, Value? new_value) {
            //lock (model_state) {
                if (model_state == null && new_value == null) {
                    return;
                }
                Value? old_value = null;

                    if (model_state != null && model_state.strdup_contents () != "NULL") {
                        old_value = model_state;
                    }

                    before_value_changed (old_value);

                if (new_value != null) {
                    // the model_state's set in the getter func...
                    this.model_value = new_value;
                } else {
                    // notify on null value when the state is null but was not null previously.
                    model_state = null;
                    notify_property (PROP_NAME);
                }
            //}
        }
    }
}
