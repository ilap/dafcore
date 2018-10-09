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

    public interface IListModel<G> : Object {
        public abstract signal void item_removed (int index);
        public abstract signal void item_added (int index);
        public abstract signal void list_changed (int size);
        public abstract signal void item_changed (int index, G item);

        public abstract int get_length ();

        public abstract G? get_at (int index);
        public abstract void set_at (int index, G value);

        public abstract bool add (G item);
        public abstract bool add_all (Collection<G> items);
        public abstract void insert (int index, G item);

        public abstract bool remove (G item);
        public abstract G remove_at (int index);

        public abstract int index_of (G? item);

        public abstract void clear ();
    }
}