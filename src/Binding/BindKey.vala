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

using Gee;

namespace Daf.Core.Binding {

    public class BindKey : Object {

        private static HashDataFunc? object_hash_func = Functions.get_hash_func_for (typeof (Object));
        private static HashDataFunc? string_hash_func = Functions.get_hash_func_for (typeof (string));

        private Object subject;
        public string property_name;

        public BindKey (Object subject, string property_name) {
            this.subject = subject;
            this.property_name = property_name;
        }

        internal static bool key_equal_func (BindKey a, BindKey b)
        requires (a.subject != null && b.subject != null &&
                  a.property_name != null && b.property_name != null) {

            return a.subject.get_type () == b.subject.get_type () &&
                    a.subject == b.subject &&
                    a.property_name == b.property_name;
        }

        /**
         * The hash is calculated from the object and property_name's hashes.
         */
        internal static uint key_hash_func (BindKey a)
        requires (a.subject != null && a.property_name != null) {

            var obj_hash = object_hash_func (a.subject).to_string ();
            var prop_hash = string_hash_func (a.property_name).to_string ();

            return string_hash_func (obj_hash + prop_hash);
        }
    }
}
