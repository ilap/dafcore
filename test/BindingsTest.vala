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
using Daf.Core.Binding;
using Daf.UnitTest;

using Daf.Core.Test.Model;

namespace Daf.Core.Test {

    /* TODO: We should have a bunch of tests
     * TODO: We just have some base tests instead of some really
     * complex ones.
     */
    public class BindingsTest : AbstractTestCase {

        Person person_a;
        Person person_b;

        Binder binder;

         public BindingsTest () {
            base ("BindingsTest");

            add_test ("bind_aspect_adapter_test",
                                    bind_aspect_adapter_test);

        /*    add_test ("bind_valueholder_to_object_test",
                                    bind_valueholder_to_object_test);

            add_test ("cyclical_dependency_test",
                                    cyclical_dependency_test);
            add_test ("rebind_test",
                                    rebind_test);
            add_test ("multiple_bind_unbind_test",
                                    multiple_bind_unbind_test);
            add_test ("bind_object_to_object_test",
                                    bind_object_to_object_test);
            add_test ("bind_object_to_valueholder_test",
                                    bind_object_to_valueholder_test);
            add_test ("bind_valueholder_to_valueholder_test",
                                    bind_valueholder_to_valueholder_test);
           */

        }

        public override void set_up () {
            person_a = new Person ();
            person_b = new Person ();

            binder = new Binder ();

        }

        public override void tear_down () {
            person_a = null;
            person_b = null;

            //binder.unbind_all ();
            binder = null;
        }

        // Unit tests...

        public void bind_aspect_adapter_test () {

            person_a.first_name = "Adam";
            person_b.first_name = "Bob";

            //var adapter_a = new AspectAdapter (person_a, "first_name");
            //var adapter_b = new AspectAdapter (person_b, "first_name");

            //assert ((string) adapter_a.get_val () == "Adam");
            //assert ((string) adapter_b.get_val () == "Bob");

            debug ("##################### BIND");
            binder.bind (person_a, "first_name"). to (person_b, "first_name");
            assert (person_b.first_name == "Adam");

            person_a.first_name = "Bob";
            assert (person_b.first_name == "Bob");

            person_a.first_name = "Adam";
            assert (person_b.first_name == "Adam");

            debug ("@@@@@@@@@@@@@@@@@@@@@ START");
            person_b.first_name = "Bob";

            assert (person_a.first_name == "Bob");

            debug ("@@@@@@@@@@@@@@@@@@@@@  END");





                //binder.bind (adapter_a). to (adapter_b);

            //assert ((string) adapter_b.get_val () == "Adam");

        }

        /*
         * On cyclical dependency (A refers B and B refers A) the new
         * binding should not be applied.
         */
        public void cyclical_dependency_test () {
            var a = new ValueHolder ();
            var b = new ValueHolder ();
            var c = new ValueHolder ();

            binder.bind (a).to (b);
            binder.bind (b).to (c);
            binder.bind (c).to (a);
            binder.bind (c).to (b);
        }

        /*
         * On rebind we just need do unbind internally to release
         * the references.
         */
        public  void rebind_test () {
        }

        public void multiple_bind_unbind_test () {

        }

        public void bind_object_to_object_test () {

            binder.bind (person_a, "first_name").to (person_b, "last_name");


            // binder.bind (person_b, "first_name").to (person_a, "first_name");

            // Initially they should be null but in reverse test will fail
            // as the Object's will be already created/initialized when
            // this func run.
            //// assert (person_a.first_name == null);
            //// assert (person_b.first_name == null);


            person_a.first_name = "Jules";
            message ("person last name %s", person_b.last_name);
            assert (person_b.last_name == "Jules");

            person_b.last_name = "Ivan";
            assert (person_a.first_name == "Ivan");

            binder.unbind (person_a, "first_name").from (person_b, "last_name");

            person_a.first_name = "Fred";
            assert (person_b.last_name == "Ivan");

            person_b.last_name = "Jules";
            assert (person_a.first_name == "Fred");

            // rebind: property1 will overwrite property2
            binder.bind (person_a, "first_name").to (person_b, "last_name");
            assert (person_a.first_name == "Fred");
            assert (person_b.last_name == "Fred");

            binder.unbind (person_a, "first_name").from (person_b, "last_name");
        }

        public  void bind_object_to_valueholder_test () {

            var vh1 = new ValueHolder ();

            person_a.first_name = "Fred";
            binder.bind (person_a, "first_name").to (vh1);

            assert ((string) vh1.get_val () == "Fred");

             vh1.set_val ("Ignaz");
            assert (person_a.first_name == "Ignaz");

            person_a.first_name = "Levin";
            assert ((string) vh1.get_val () == "Levin");

            // Unbind
            binder.unbind (person_a, "first_name").from (vh1);
        }

        public void bind_valueholder_to_object_test () {
            var vh = new ValueHolder ();
            person_a.first_name = "Empty";

            IBindTo bindto = binder.bind (vh);
            debug ("bindto created");



            bindto.to (person_a, "first_name");
            debug ("person_a created");
            vh.set_val ("Jules");

            assert ((string) vh.get_val () == "Jules");
            assert (person_a.first_name == "Jules");
         }

        public void bind_valueholder_to_valueholder_test () {
            var vh1 = new ValueHolder ();
            var vh2 = new ValueHolder ();

            vh1.set_val ("Jules");
            binder.bind (vh1).to (vh2);
            assert ((string) vh2.get_val () == "Jules");

            vh2.set_val ("Fred");
            assert ((string) vh1.get_val () == "Fred");

            binder.bind (vh1).to (vh2);

            vh2.set_val ("Jules");
            assert ((string) vh1.get_val () == "Jules");

            binder.unbind (vh1).from (vh2);
            vh1.set_val ("Final String");
            assert ((string) vh2.get_val () == "Jules");
        }
    }
}