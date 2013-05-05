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

    // TODO: change assert to Assert.func...
    public class AspectTriggerTest : AbstractTestCase {

         public AspectTriggerTest () {
            base ("AspectTriggerTest");

            add_test ("test_three_state", test_three_state);
            add_test ("test_trigger_commit", test_trigger_commit);
            add_test ("test_trigger_discard", test_trigger_discard);
        }

        public override void set_up () {

        }

        public override void tear_down () {

        }


        public void test_three_state () {

            IValueModel at = new AspectTrigger ();

            // Initial value must be false;
            assert (at.get_val () == null );

            at.set_val (true);
            assert ((bool) at.get_val () == true );

            at.set_val (false);
            assert ((bool) at.get_val () == false );

            at.set_val (null);
            assert (at.get_val () == null );
        }



        public void test_trigger_commit () {

            var t = new AspectTrigger ();
            var vh = new ValueHolder ();
            var bvh = new BufferedValueHolder.with_trigger (vh, t);

            // TODO: Test these in ValueHolder's Cases.
            //Assert.is_true (bvh.get_val () == null, "Initial value of Buffered Value Model is not NULL");
            //Assert.is_true (vh.get_val () == null, "Initial value of Buffered Value Model is not NULL"));

            vh.set_val ("Subject value");

            assert ("Subject value" == (string) vh.get_val ());
            debug ("XXXXXXXX");
            assert ((string) bvh.get_val () == (string) vh.get_val ());


            vh.set_val ("New value");
            assert ((string) bvh.get_val () == (string) vh.get_val ());


            vh.set_val (null);
            assert (bvh.get_val () == vh.get_val ());



            //
            Value new_value = "Init value";

            bvh.set_val (new_value);
            vh.set_val ("New Value");
            assert ((string)bvh.get_val () == (string) new_value);

            vh.set_val (new_value);
            assert ((string)bvh.get_val () == (string) new_value);

            vh.set_val (null);
            assert ( (string) bvh.get_val () ==  (string) new_value);

            // Discard changes
            vh.set_val ("Init value");

            bvh.set_val ("changed"); // make it dirty

            //t2.discard ();
            t.discard ();
            assert ( (string) vh.get_val () == (string) bvh.get_val ());

            vh.set_val ("changed now");
            assert ( (string) vh.get_val () == (string) bvh.get_val ());

            vh.set_val ("changed again");
            t.discard ();
            assert ( (string) vh.get_val () == (string) bvh.get_val ());

            // Old value checks
            var old_value = vh.get_val ();
            bvh.set_val ("12345");
            assert ((string)vh.get_val () == (string) old_value);

            bvh.set_val (null);
            assert ((string)vh.get_val () == (string) old_value);

            bvh.set_val (old_value);
            assert ((string)vh.get_val () == (string) old_value);

            bvh.set_val ("54321");
            assert ((string)vh.get_val () == (string) old_value);

            // Commit tests
            vh.set_val ("initial_value");
            old_value = vh.get_val ();
            new_value = "new value";
            bvh.set_val (new_value);
            assert ((string) vh.get_val () == (string) old_value);

            t.commit ();
            assert ((string)vh.get_val () == (string) new_value);

            var new_value1 = vh.get_val ();
            bvh.set_val (new_value1);
            t.commit ();
            assert ((string)vh.get_val () == (string) new_value1);

            // Discard tests
            vh.set_val ("initial_value");
            new_value = "new value";

            bvh.set_val (new_value);
            assert ((string) bvh.get_val () == (string) new_value1);

            t.discard ();
            assert ((string) bvh.get_val () == (string) vh.get_val ());

            new_value1 = vh.get_val ();
            bvh.set_val (new_value1);

            assert ((string) bvh.get_val () == (string) new_value1);

            t.discard ();
            assert ((string) bvh.get_val () == (string) vh.get_val ());

            // Dirty check
            new_value = "1324";
            vh.set_val (new_value);
            // clear the state
            t.discard ();
            assert (bvh.dirty == false);

            vh.set_val (new_value);
            assert (bvh.dirty == false);

            vh.set_val (new_value);
            assert (bvh.dirty == false);

            bvh.set_val ("0987");
            assert (bvh.dirty == true);

            bvh.set_val ("1987");
            assert (bvh.dirty == true);

            bvh.set_val ("2987");
            assert (bvh.dirty == true);

            t.commit ();
            assert (bvh.dirty == false);

            new_value = "changed again";
            vh.set_val (new_value);
            assert (bvh.dirty == false);

            vh.set_val (null);
            assert (bvh.dirty == false);

            bvh.set_val ("452312");
            assert (bvh.dirty == true);

            t.discard ();
            assert (bvh.dirty == false);

            new_value = "changed again";
            vh.set_val (new_value);
            assert (bvh.dirty == false);

            vh.set_val (null);
            assert (bvh.dirty == false);
        }

        public void test_trigger_discard () {

        }

     }
}