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

namespace Daf.Core {

    /**
     * Using Decorator Pattern for convert Values
     */
    public abstract class AbstractTypeConverter: AbstractValueHolder {
        protected IValueModel model;

        public AbstractTypeConverter (IValueModel model) {
            this.model = model;
            // Connect the property change notification to the wrapper class.
            model.notify[IValueModel.PROP_NAME].connect ((s, p) => {
                notify_property (IValueModel.PROP_NAME);
            });
        }

        public abstract Value convert_from_model (Value? model_value);

        public override Value? get_val () {
            // FIXME: Remove it debug ("GETVAL %s", (model.get_val() == null).to_string ());
            return convert_from_model (model.get_val());
        }
    }
}
