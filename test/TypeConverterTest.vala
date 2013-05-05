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
     * Using Decorator Pattern for convert Values
     */
    public class TypeConverterTest : AbstractTestCase {

        Person person;

         public TypeConverterTest () {
            base ("TypeConverterTest");

            add_test ("integer_to_string_converter_test", integer_to_string_converter_test);
        }

        public override void set_up () {
            person = new Person ();
            person.first_name = "Felix";
            person.last_name = "Van der Gullen";
            person.age = 42;
            person.sex = Gender.MALE;
            person.email = "felix.van.der.gullen@gmail.com";

        }

        public override void tear_down () {
            person = null;
        }

        public void integer_to_string_converter_test () {

            IValueModel int_model = new AspectAdapter (person, "age");
            IValueModel str_model = new IntToStringConverter (int_model);

            person.age = 1;
            assert (1 == (int) int_model.get_val ());//.get_int ());
            assert ("1" == (string) str_model.get_val());

            str_model.set_val ("2");
            assert (2 == person.age);
        }

        /*
         * Nested Class for Integer To String Converter
         */
        public class IntToStringConverter : AbstractTypeConverter {

            public IntToStringConverter (IValueModel value_model) {
                base (value_model);
            }

            public override Value convert_from_model (Value? model_value) {
                return ((int) model_value).to_string ();
            }

            public override void set_val (Value? new_value) {
                model.set_val (int.parse ((string) new_value));
            }
        }
    }
}
