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

    public class AspectAdapterTest : AbstractTestCase {

        private Person person1;
        private Person person2;

        private AspectAdapter aspect_adapter;
        private ValueHolder value_holder;

        public AspectAdapterTest () {
            base ("AspectAdapterTest");

            add_test ("test_adapter_value_is_null", test_adapter_value_is_null);
            add_test ("test_adapter_value_is_not_null", test_adapter_value_is_not_null);
            add_test ("test_change_model", test_change_model);
            //add_test ("test_modeltype_differ", test_modeltype_differ);
            add_test ("test_direct_access", test_direct_access);
            add_test ("test_indirect_access", test_indirect_access);

        }

        public override void set_up () {
            person1 = new Person ();
            //person1.first_name =  "Fred";


            person2 = new Person ();
            //person2.first_name =  "Ivan";

            value_holder = new ValueHolder ();

            // Bind to the first_name
            aspect_adapter = new AspectAdapter (value_holder, "first_name", true);

            //person1.notify["first-name"].connect (()=>{ debug ("person1.first_name modified");});
            //person2.notify["first-name"].connect (()=>{ debug ("person2.first_name modified");});
            //aspect_adapter.notify[IValueModel.PROP_NAME].connect (()=>{ debug ("persons fn should be modified");});
            //value_holder.notify[IValueModel.PROP_NAME].connect (()=>{ debug ("valuholder modified");});
        }

        public override void tear_down () {
            person1 = null;
            person2 = null;

            value_holder = null;
            aspect_adapter = null;
        }


        public void test_adapter_value_is_null () {
            assert (aspect_adapter.get_val () == null);
        }

        public void test_adapter_value_is_not_null () {

            aspect_adapter.set_model (null);

            assert (aspect_adapter.get_model () == null);
            assert (aspect_adapter.get_val () == null);

            aspect_adapter.set_model (person1);

            person1.first_name = "Fred";
            debug ("Should be fired....");
            assert ((string) aspect_adapter.get_val () == "Fred");

        }

        public void test_change_model () {
            assert (aspect_adapter.get_model () == null);
            assert (aspect_adapter.get_val () == null);

            aspect_adapter.set_model (person1);
            //initial it must be empty string
            //.changed ("SSS %s", (string) aspect_adapter.get_val ());
            //assert (aspect_adapter.get_val () == null);
            debug ("OK");
            person1.first_name = "Fred";
            assert ((string) aspect_adapter.get_val () == "Fred");

            aspect_adapter.set_model (null);
            assert (aspect_adapter.get_val () == null);

            aspect_adapter.set_model (person2);
            //assert (aspect_adapter.get_val () == null);

            person2.first_name = "Ivan";
            assert ((string) aspect_adapter.get_val () == "Ivan");
        }

        public void test_direct_access () {

            var aspect_adapter = new AspectAdapter (person1, "first_name");
            aspect_adapter.set_val ("Ignaz");
            assert (person1.first_name == "Ignaz");
            debug ("AA:");
            assert ((string) aspect_adapter.get_val () == "Ignaz");

            aspect_adapter.set_model (person2);
            //assert (person2.first_name == null);
            //assert (aspect_adapter.get_val () == null);

            person2.first_name = "Humer";
            assert ((string) person2.first_name == "Humer");
            assert ((string) aspect_adapter.get_val () == "Humer");
        }

        public void test_indirect_access () {

             // Indirect access
            assert (aspect_adapter.get_val () == null);
            assert (aspect_adapter.get_model () == null);

             value_holder.set_val (person1);
            // TODO: test_adapter_value_is_null if the prop is string? and "" if the pfop is string
            //assert (aspect_adapter.get_val () == null);

            person1.first_name = "Jules";
            assert ((string) aspect_adapter.get_val () == "Jules");
            assert (person1.first_name == "Jules");

             value_holder.set_val (person2);
            //assert (aspect_adapter.get_val () == null);

            person2.first_name = "Humer";
            assert ((string) aspect_adapter.get_val () == "Humer");
            assert (person2.first_name == "Humer");

         }
    }
}

