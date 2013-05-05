/**
 * Copyright (c) 2012-2013 Pal Dorogi <pal.dorogi@gmail.com>
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

namespace Daf.Core {

    /**
     * This implements swapping a wrapped model in a wrapper class.
     */
    public interface IModelHolder : Object {
        public const string PROP_NAME = "value-model";
        public abstract IValueModel? value_model { protected get; protected set; }
          //public signal void model_changed ();

        public abstract Object? get_model ();
        public abstract void set_model (Object? new_model);

        public virtual IValueModel? get_channel () {
            return value_model;
        }

        public virtual void set_channel (IValueModel? value_model) {
            this.value_model = value_model;
        }
    }
}


