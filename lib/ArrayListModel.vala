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

namespace Daf.Core {

    public class ArrayListModel<G> : Gee.ArrayList<G>, IListModel<G> {

        public G? get_at (int index) {
            debug ("ArrayListModel:get_at: index %d size %d", index, size);
            return base.get (index);
        }

        public void set_at (int index, G value)
            requires (index >= 0 && index < size) {

            base.set (index, value);
            item_changed (index, value);
        }

        public override bool add (G item) {
            debug ("ArrayList: add");
            bool result = base.add (item);

            if (result == true) {
                list_changed (size);
                item_added (index_of (item));
            }
            return result;
        }

        // TODO: it's not abstract anymore in Gee
        public new bool add_all (Collection<G> items) {
            debug ("ArrayList: add all");

            bool result = false;

            foreach (var item in items) {
                result &= add (item);
                item_added (index_of (item));
                list_changed (size);
            }
            return result;
        }

        public override void insert (int index, G item) {
            debug ("ArrayList: insert item %d", index);
            base.insert (index, item);
            item_added (index);
            list_changed (size);
        }

        public override bool remove (G item) {
            debug ("ArrayList: remove");
            return base.remove (item);

        }

        public override G remove_at (int index) {
            debug ("ArrayList: removed_at: %d", index);
            G? result = base.remove_at (index);

            if (result != null) {
                item_removed (index);
                list_changed (size);
            }
            return result;
        }

        public override void clear () {
            var length = get_length ();

            for (int i = 0; i<length; i++) {
                remove_at (0);
            }
        }

        public int get_length () {
            return size;
        }
    }
}