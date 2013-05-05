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

    public class ModelPresenterTest : AbstractTestCase {

        ValueHolder value_holder;

         public ModelPresenterTest () {
            base ("ModelPresenterTest");

            add_test ("change_model_under_presenter_test",
                                change_model_under_presenter_test);
            add_test ("base_test", base_test);

        }

        public override void set_up () {
            value_holder = new ValueHolder ();
        }

        public override void tear_down () {
            value_holder = null;
        }

        public void change_model_under_presenter_test () {
            var person_a = new Person ("Humer", "Troppauer");
            var person_b = new Person ("Jules", "Manfred Harrincourt");

            var vh = new ValueHolder (person_a);
            //vh.notify[IValueModel.PROP_NAME].connect (() => { debug ("Value has.changed");});

            var presenter = new ModelPresenter (vh);
            var first_name = presenter.get_value_model ("first_name");

            assert ((string) first_name.get_val () == "Humer");

            vh.set_val (person_b);
            assert ((string) first_name.get_val () == "Jules");
        }

        public void base_test () {

            var pal = new Person ("Pal", "Dorogi");
            var pal_address = new Address ("13", "LDDRD GDNS", 6171);

            var agnes = new Person ("Agnes", "Dorogi");
            var agnes_address = new Address ("13", "LDDRD GDNS", 6171);

            pal.address = pal_address;
            agnes.address = agnes_address;

            var vh = new ValueHolder (pal);
            //var presenter = new ModelPresenter.with_object (pal);
            //var presenter = new ModelPresenter (vh);
            var presenter = new ModelPresenter (pal);

            pal.first_name = "Jozska";

            var first_name = presenter.get_value_model ("first_name");

            vh.set_val (agnes);

            var contact = new Person ("Pal", "Dorogi");
            var address = new Address ("13", "LDDRD GDNS", 6171);
            contact.address = address;


            presenter = new ModelPresenter (contact);

            first_name = presenter.get_value_model ("first_name");
            IValueModel first_name2 = presenter.get_value_model ("first_name");
            assert (first_name == first_name2);

            IValueModel last_name = presenter.get_value_model ("last_name");

            IValueModel post_code = presenter.get_value_model ("address.post_code");
            assert ( (string) first_name.get_val () == "Pal");
            assert ( (string) last_name.get_val () == "Dorogi");
            assert ( (int) post_code.get_val () == 6171);


            first_name.set_val ("Agnes");
            last_name.set_val ("Dorogi-Kaposi");
            post_code.set_val (9999);

            assert ( contact.first_name == "Pal");
            assert ( contact.last_name == "Dorogi");
            assert ( address.post_code == 6171);

            presenter.commit ();

            assert ( contact.first_name == "Agnes");
            assert ( contact.last_name == "Dorogi-Kaposi");
            assert ( address.post_code == 9999);

            // Make it dirty
            first_name.set_val ("Agica");
            last_name.set_val ("Dorogi-Kaposi2");
            post_code.set_val (7777);

            assert ( (string) first_name.get_val () == "Agica");
            assert ( (string) last_name.get_val () == "Dorogi-Kaposi2");
            assert ( (int) post_code.get_val () == 7777);

            assert ( contact.first_name == "Agnes");
            assert ( contact.last_name == "Dorogi-Kaposi");
            assert ( address.post_code == 9999);

            presenter.discard ();

            assert ( (string) first_name.get_val () == "Agnes");
            assert ( (string) last_name.get_val () == "Dorogi-Kaposi");
            assert ( (int) post_code.get_val () == 9999);
        }
    }
}