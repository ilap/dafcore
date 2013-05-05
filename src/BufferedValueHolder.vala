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
     * It's a ValueModel that wraps an other model using decorating pattern.
     *
     * This model delays changes of the wrapped model and return model's
     * value until its state is not dirty.
     * Dirty state means a value has been set internally but written to the
     * model.
     *
     * The buffered value is just written to the model when the associated trigger is
     * committed or the commit () method directly called.
     * Also, the buffered value can be discarded using trigger's discard signal or the
     * internal discard () method.
     *
     * Behaviors:
     *     * Buffered model's getter/setter methods:
     *        = get_value () returns /w the initialy set subject's value if it's not dirty
     *        = get_value () returns the buffered value if it's dirty.
     *        = set_value (value) will set its internal value and dirty state but
     *            the subject's value  won't be.changed;
     *    * Wrapped model's getter/setter methods:
     *        = get_value () returns /w its value.
     *        = set_value () will set its value and notify the buffered model which
     *            behaves based on its dirty stage.
     *    * If buffered model holds a channel:
     *        = it will clean dirty state and copy value from the channel using
     *            IModelHolder's model_changed signal.
     *
     * If the subject is a IModelHolder then the discard will be called to clear the
     * buffer and set the buffer /w the new subject's value. This because the subject
     * behaving as a channel -> underlaying POCO is swapped to an other one.
     *
     **/
    public class BufferedValueHolder : AbstractValueHolder, IAspectTrigger {

        public bool auto_commit { get; set; default = false; }
        public bool dirty { get; protected set; default = false; }
        private bool observe_model_changes;


        public IValueModel? subject { public get ; protected set; }

        /**
         * Each view could contain multiple groups of BufferedValueHolders,
         * each group sharing its own trigger.
         * This implemention uses Three-State logic.
         * States: null: Nothing happens, true: commit; false: discard;
         */
        public IAspectTrigger trigger { get; set; }

        // Constructors
        public BufferedValueHolder (IValueModel subject, bool observe_model_changes = false) {
            this.dirty = false;
            this.subject = subject;
            this.observe_model_changes = observe_model_changes;

            if (subject is IModelHolder && observe_model_changes) {
                // The underlayed model has.changed, so discard any changes on the buffered values.
                var channel = (this.subject as IModelHolder).get_channel ();
                channel.notify[PROP_NAME].connect (model_changed);
            }

            base.set_val (subject.get_val ());
            this.subject.notify[PROP_NAME].connect (value_changed);


        }

        ~BufferedValueHolder () {
             if (subject is IModelHolder && observe_model_changes) {
                // The underlayed model has.changed, so discard any changes on the buffered values.
                var channel = (this.subject as IModelHolder).get_channel ();
                channel.notify[PROP_NAME].disconnect (model_changed);
            }
        }

        public BufferedValueHolder.with_trigger (IValueModel subject, IAspectTrigger trigger) {
            this (subject);
            this.trigger = trigger;

            this.trigger.notify[IValueModel.PROP_NAME].connect (trigger_emitted_handler);
        }

        public override void set_val (Value? new_value) {
            lock (dirty) {

                dirty = new_value != null || new_value == null && get_val () != null;
                debug ("BufferedValueHolder.set_val: dirty: %s", dirty.to_string ());
                base.set_val (new_value);
            }
        }

        private void commit () {
            lock (dirty) {
                debug ("BufferedValueHolder.commit: dirty: %s", dirty.to_string ());
                if (dirty == true) {
                    subject.set_val (base.get_val ());
                    dirty = false;
                }
            }
        }

        private void discard () {
            lock (dirty) {
                debug ("BufferedValueHolder.discard: dirty: %s", dirty.to_string ());
                base.set_val (subject.get_val ());
                dirty = false;
            }
        }

        public void model_changed () {
            debug ("Model has.changed discarding it...");
            discard ();
        }

        public void value_changed (Object sender, ParamSpec spec) {
            debug ("value_changed");
            lock (dirty) {
                if (dirty == false || (dirty == true && subject is IModelHolder)) {
                    if (dirty == true) {
                        dirty = false;
                    }
                    base.set_val (subject.get_val());
                }
            }
        }

        public void trigger_emitted_handler (Object sender, ParamSpec spec) {
            var aspect_trigger = sender as IValueModel;
            var value = aspect_trigger.get_val ();

            if (value != null) {
                if ((bool) value == true) {
                    commit ();
                } else {
                    discard ();
                }
            }
        }
    }
}
