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
using Daf.UnitTest;
using Daf.Core.Test.Model;

namespace Daf.Core.Test {

    /**
     * Buffered Value Holder is a ValueModel which wraps an other
     * ValueModel and delays it's modification until it's commited
     * or discarded.
     *
     * If the wrapped model's value change it will overwrite the buffered
     * value model's one until it's not dirty.
     *
     * If the buffered model's state.changed to dirty (meas set its value
     * by set_val ()) the domain model cannot overwrite the buffered value
     * model's value anymore until the state's cleared means:
     * = discard (): wrapped model overwrites the buffered model's value.
     * = or commit (): buffered model overwrites the wrapped model's value.
     *
     * Example:
     * var vh = new ValueHolder ()
     * var bvh = new BufferedValueHolder (a);
     * // Both value is null
     * value_holder.set_val (1); // Bvh does not know anything the change.
     * buffered_model.commit (); // bvh's value will be set to 1 as it's state is not dirty
     * buffered_model.set_val (2);// Sets internal state to dirty
     *
     * value_holder.set_val (3); // The bvh's value won't be.changed as it's state is dirty.
     * // Means bvh = 2 and vh = 3.
     *
     *
     * In brief:
     * = On discard, the bvh is reset /w the vh's value
     * = On commit if bvh is NOT dirty: It will be reset to the vh's value.
     * = On commit if bvh is dirty: the bvh will set the vh's value
     *   and will clear its dirty state.
     *
     * = The bvh value is always the same /w vh value until it's state to dirty;
     *
     **/
    public class BufferedValueHolderTest : AbstractTestCase {

        Person person_a;
        Person person_b;

        IValueModel value_holder;
        BufferedValueHolder buffered_model;

         public BufferedValueHolderTest () {
            base ("BufferedValueHolderTest");

            add_test ("value_changes_test",
                        value_changes_test);
            add_test ("commit_test",
                        commit_test);
            add_test ("discard_test",
                        discard_test);
            add_test ("dirty_test",
                        dirty_test);
            add_test ("change_wrapped_model_test",
                        change_wrapped_model_test);
            add_test ("random_test",
                        random_test);

        }

        public override void set_up () {
            value_holder = new ValueHolder ();
            buffered_model = new BufferedValueHolder (value_holder);

            person_a = new Person ();
            person_b = new Person ();
        }

        public override void tear_down () {
            value_holder = null;
            buffered_model = null;

            person_a = null;
            person_b = null;
        }

        public void value_changes_test () {

            // They both should be null
            assert (value_holder.get_val () == null);
            assert (buffered_model.get_val () == value_holder.get_val ());

            // Set wrapped model to the initial value which sets the
            // buffered model to the same.
            value_holder.set_val ("initial");
            assert ((string) value_holder.get_val () == "initial");

             assert ((string) buffered_model.get_val () == (string) value_holder.get_val ());


            // Make bvh dirty
            buffered_model.set_val ("dirty");

            // Try to overwrite bvh's value
            value_holder.set_val ("try to overwrite");

            // The buffered model's value remains the old value
            // due the buffered model got dirty.
            assert ((string) buffered_model.get_val () == "dirty");
            assert ((string) value_holder.get_val () == "try to overwrite");
        }

        public void commit_test () {

            value_holder.set_val ("initial");
            // They both should be same due the buffered model is not dirty
            assert ((string) value_holder.get_val () == "initial");
            assert ((string) value_holder.get_val () == (string) buffered_model.get_val ());

            buffered_model.set_val ("changed"); // make it dirty
            //
            assert ((string) value_holder.get_val () == "initial");
            assert ((string) buffered_model.get_val () == "changed");

            buffered_model.commit ();

            assert ((string) value_holder.get_val () == "changed");
            assert ((string) buffered_model.get_val () == "changed");
        }

        public void discard_test () {

            value_holder.set_val ("initial");
            // They both should be same due the buffered model is not dirty
            assert ((string) value_holder.get_val () == "initial");
            assert ((string) value_holder.get_val () == (string) buffered_model.get_val ());

            buffered_model.set_val ("changed"); // make it dirty
            //
            assert ((string) value_holder.get_val () == "initial");
            assert ((string) buffered_model.get_val () == "changed");

            buffered_model.discard ();

            assert ((string) value_holder.get_val () == "initial");
            assert ((string) buffered_model.get_val () == "initial");

        }

        public void dirty_test () {
        
            // The buffered model should be clean state initialy
            assert (buffered_model.dirty == false);

            value_holder.set_val ("initial");

            // The buffered model should not be dirty after the wrapped
            // model's value change.
            assert (buffered_model.dirty == false);

            buffered_model.set_val (1234567);
            // The dirty should be true
            assert (buffered_model.dirty == true);

            buffered_model.discard ();
            // The buffered model should not be dirty after discard
            // and its value should be set back to the model's value.
            assert (buffered_model.dirty == false);
            assert ((string) buffered_model.get_val () == "initial");
        }

        public void change_wrapped_model_test () {

            // Initially they must be null...
            var aspect_adapter = new AspectAdapter (person_a, "first_name");
            var buffered_model = new BufferedValueHolder (aspect_adapter, true);

            //assert (aspect_adapter.get_val () == null);
            //assert (buffered_model.get_val () == null);


            // Make it dirty
            buffered_model.set_val ("Levin");
            // Buffered model should be dirty
            assert (buffered_model.dirty == true);
            //assert (aspect_adapter.get_val () == null);
            //buffered_model.discard ();

            // Change the model under aspect adapter.
            aspect_adapter.set_model (person_b);

            // Buffered model's dirty state should be cleared.
            assert (buffered_model.dirty != true);
            //assert (aspect_adapter.get_val () == null);
            //assert (buffered_model.get_val () == null);

             ///////////////////////////////////////////////////////////////
            // Buffered model's dirty state should be cleared.
            person_a.first_name = "Ignaz";
            person_b.first_name = "Humer";

            aspect_adapter.set_model (null);

            assert (buffered_model.dirty != true);
            assert (aspect_adapter.get_val () == null);
            assert (buffered_model.get_val () == null);

            // Aspect Adapter and buffered model's value should be set to person_a.first_name;
            aspect_adapter.set_model (person_b);
            assert ((string) aspect_adapter.get_val () == "Humer");
            assert ((string) buffered_model.get_val () == "Humer");
            // Make it dirty
            buffered_model.set_val ("Levin");
            // Buffered model should be dirty
            assert (buffered_model.dirty == true);
            assert ((string) aspect_adapter.get_val () == "Humer");

            // Change the model under aspect adapter.
            aspect_adapter.set_model (person_a);

            // Buffered model should still be dirty.
            assert (buffered_model.dirty != true);

            // aspect adapter should have the new value
            assert ((string) aspect_adapter.get_val () == "Ignaz");
            // buffered model should have the dirty value
            assert ((string) buffered_model.get_val () == "Ignaz");

            buffered_model.discard ();
            // buffered model should have the discarded value
            assert ((string) buffered_model.get_val () == "Ignaz");

            // Do the same but without dirty buffered model
            // Change the model back to person_a under aspect adapter.
            aspect_adapter.set_model (person_a);
            assert ((string) aspect_adapter.get_val () == "Ignaz");

            // buffered model should have the person_a's first name -> Humer
            assert ((string) buffered_model.get_val () == "Ignaz");


            /**
             * Test /w dirty buffered model
             **/
            // Make it dirty
            buffered_model.set_val ("Levin");
            // Buffered model should be dirty

            assert (buffered_model.dirty == true);
            assert ((string) aspect_adapter.get_val () == "Ignaz");

            aspect_adapter.set_model (person_b);
            assert ((string) aspect_adapter.get_val () == "Humer");

            // buffered model should have the person_a's first name -> Humer
            assert ((string) buffered_model.get_val () == "Humer");

            buffered_model.set_val ("Levin");
            buffered_model.commit ();
            // The committed aspect adapter and the.changed model should have the
            // newly applied value (Levin)
            assert ((string) aspect_adapter.get_val () == "Levin");
            assert ((string) person_b.first_name == "Levin");
        }

        public void random_test () {

            buffered_model.discard ();
            assert (value_holder.get_val () == buffered_model.get_val ());

            value_holder.set_val ("changed now");
            assert ((string) value_holder.get_val () == (string) buffered_model.get_val ());

            value_holder.set_val ("changed again");
            buffered_model.discard ();
            assert ((string) value_holder.get_val () == (string) buffered_model.get_val ());

            // Old value checks
            var old_value = value_holder.get_val ();
            buffered_model.set_val ("12345");
            assert ((string)value_holder.get_val () == (string) old_value);

            buffered_model.set_val (null);
            assert ((string)value_holder.get_val () == (string) old_value);

            buffered_model.set_val (old_value);
            assert ((string)value_holder.get_val () == (string) old_value);

            buffered_model.set_val ("54321");
            assert ((string)value_holder.get_val () == (string) old_value);

            // Commit tests
            Value new_value = "new_value";
            value_holder.set_val ("initial_value");
            old_value = value_holder.get_val ();
            new_value = "new value";
            buffered_model.set_val (new_value);
            assert ((string) value_holder.get_val () == (string) old_value);

            buffered_model.commit ();
            assert ((string)value_holder.get_val () == (string) new_value);

            var new_value1 = value_holder.get_val ();
            buffered_model.set_val (new_value1);
            buffered_model.commit ();
            assert ((string)value_holder.get_val () == (string) new_value1);

            // Discard tests
            value_holder.set_val ("initial_value");
            new_value = "new value";

            buffered_model.set_val (new_value);
            assert ((string) buffered_model.get_val () == (string) new_value1);

            buffered_model.discard ();
            assert ((string) buffered_model.get_val () == (string) value_holder.get_val ());

            new_value1 = value_holder.get_val ();
            buffered_model.set_val (new_value1);

            assert ((string) buffered_model.get_val () == (string) new_value1);

            buffered_model.discard ();
            assert ((string) buffered_model.get_val () == (string) value_holder.get_val ());

            // Dirty check
            new_value = "1324";
            value_holder.set_val (new_value);
            // clear the state
            buffered_model.discard ();
            assert (buffered_model.dirty == false);

            value_holder.set_val (new_value);
            assert (buffered_model.dirty == false);

            value_holder.set_val (new_value);
            assert (buffered_model.dirty == false);

            buffered_model.set_val ("0987");
            assert (buffered_model.dirty == true);

            buffered_model.set_val ("1987");
            assert (buffered_model.dirty == true);

            buffered_model.set_val ("2987");
            assert (buffered_model.dirty == true);

            buffered_model.commit ();
            assert (buffered_model.dirty == false);

            new_value = "changed again";
            value_holder.set_val (new_value);
            assert (buffered_model.dirty == false);

            value_holder.set_val (null);
            assert (buffered_model.dirty == false);

            buffered_model.set_val ("452312");
            assert (buffered_model.dirty == true);

            buffered_model.discard ();
            assert (buffered_model.dirty == false);

            new_value = "changed again";
            value_holder.set_val (new_value);
            assert (buffered_model.dirty == false);

            value_holder.set_val (null);
            assert (buffered_model.dirty == false);
        }
    }
}