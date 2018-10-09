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

namespace Daf.Core {

    public class ModelRegistrar : Object, IModelPresenter {

        private HashMap<string, IValueModel> all_models;
        private HashMap<string, IValueModel> value_models;

        /*
         * TODO: We should implement the registration of the dirty models either
         */
        public ModelRegistrar () {
            all_models = new HashMap<string, IValueModel> ();
            value_models = new HashMap<string, IValueModel> ();
        }

        public void add_value_model (string key, IValueModel value) {
            all_models.set (key, value);
            value_models.set (key, value);
        }

        public IValueModel? get_value_model (string key) {
            return value_models.get (key);
        }

         public HashMap<string, IValueModel> get_all_models () {
            return all_models;
        }
    }
}


