 // -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
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
 * MERCHANTABILITY or FIt_mESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

using Gee;

namespace Daf.Core.Test.Model {

    public class Person : Object {

        public string first_name { get; set; }
        public string last_name { get; set; }
        public string email { get; set; }

        public int age { get; set; }
        public Gender sex { get; set; }

        public Person spouse { get; set; }

        public ArrayList<Person> friends { get; set; }

        public Address address { get; set; }

        public Person (string first_name = "", string last_name = "") {
            this.first_name = first_name;
            this.last_name = last_name;
            this.sex = Gender.FEMALE;
        }
    }
}
