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

    public class ValueHolderTest : AbstractTestCase {

        private static int num_of_events = 0;

        public IValueModel value_holder;

         public ValueHolderTest () {
            base ("ValueHolderTest");

            add_test ("null_value_test", null_value_test);
            add_test ("string_value_test", string_value_test);
            add_test ("enum_value_test", enum_value_test);
        }

        public override void set_up () {
            value_holder = new ValueHolder ();
            value_holder.notify.connect (events_counter);

            // It's null by default
            assert (null == value_holder.get_val ());
        }

        public override void tear_down () {
        }

        public void events_counter () {
            num_of_events += 1;
        }

        public void null_value_test () {
             // Clear the events counter...
                num_of_events = 0;

            value_holder.set_val (null);
            // It's null by default
            assert (null == value_holder.get_val ());

            value_holder.set_val (null);
            assert (null == value_holder.get_val ());

            //
            //.changed ("Num of events: %d", num_of_events);

            // Event should not be emitted when the old and new value is null
            // It would be nice to have some Value compare funct to check the old new
            // Value values...
            assert (num_of_events == 0);

            value_holder.set_val (1);
            value_holder.set_val (null);
            assert (value_holder.get_val () == null);
             assert (num_of_events == 2);
         }

        public void enum_value_test () {
             // Clear the events counter...
                num_of_events = 0;

            value_holder.set_val (Gender.MALE);
            assert (Gender.MALE == (Gender) value_holder.get_val ());

            value_holder.set_val (Gender.FEMALE);
            assert (Gender.FEMALE == (Gender) value_holder.get_val ());
             //assert (num_of_events == 1);
             //.changed ("Number of events: %d", num_of_events);

            assert (num_of_events == 2);
        }

        public void string_value_test () {
            // Clear the events counter...
                num_of_events = 0;


            value_holder.set_val ("old");
            assert ("old" == (string) value_holder.get_val ());

            value_holder.set_val ("new");
            assert ("new" == (string) value_holder.get_val ());

            value_holder.set_val (null);
            assert (null == value_holder.get_val ());
            assert (num_of_events == 3);

        }
    }
}
