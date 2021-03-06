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
using Daf.Core;

namespace Daf.Core.Binding {

    public class DefaultBindModelRepository : Object, IBindModelRepository<BindKey, IBindModel> {
        public HashMap<BindKey, IBindModel> bind_models { get; construct set; }

        construct {
            bind_models = new HashMap<BindKey, IBindModel> (
                                (HashDataFunc?) BindKey.key_hash_func,
                                (EqualDataFunc?) BindKey.key_equal_func);
        }

        public void DefaultBindModelRepository () {
        }
    }
}

