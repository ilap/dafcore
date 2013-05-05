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

    // Decorating pattern
    public class BindModelService<K, V> : Object, IBindModelRepository<K, V>, IBindModelService {

        public IBindModelRepository repository { get; construct; }
        public IBindModelFactory model_factory { get; construct; }


        public BindModelService (IBindModelRepository repository, IBindModelFactory model_factory) {
            Object (repository : repository, model_factory : model_factory);
        }

        public HashMap<K, V> bind_models {
            get { return repository.bind_models; }
            construct set {}
        }

        public IBindModel? get_bind_model (Object subject, string? property_name = null) {

            var bind_models = repository.bind_models;
            var bind_key = resolve_bind_key (subject, property_name);

            if (bind_key != null && bind_models.has_key (bind_key)) {
                return (IBindModel?) bind_models.get (bind_key);
            }

           return null;
        }

        public IBindModel? create_bind_model (Object subject, string? property_name = null)
            requires (((subject is IValueModel) && property_name == null) ||
                      (!(subject is IValueModel) && property_name !=null)) {

            var bind_key = resolve_bind_key (subject, property_name);
                if (bind_key == null || bind_models.has_key (bind_key)) {
                return null;
            }

                var bind_models = repository.bind_models;
                IValueModel value_model;

            if (subject is IValueModel) {
                value_model = (IValueModel) subject;
                property_name = IValueModel.PROP_NAME;
            } else {
                value_model = new AspectAdapter (subject, property_name, true);
            }

            var bind_model = model_factory.get_instance (property_name, this, value_model);
            // FIXME: debug ("bind_model is null %s", (bind_model == null).to_string ());

            bind_models.set (bind_key, bind_model);
            return (IBindModel?) bind_models.get (bind_key);
        }

        public void remove_bind_model (Object subject, string? property_name = null)
        requires (((subject is IValueModel) && property_name == null) ||
                (!(subject is IValueModel) && property_name !=null)) {

            var bind_models = repository.bind_models;
            var bind_key = resolve_bind_key (subject, property_name);

            if (bind_key != null && bind_models.has_key (bind_key)) {
                bind_models.unset (bind_key);
            }
        }

        public IBindModel get_or_create_bind_model (Object subject, string? property_name = null)
        requires (((subject is IValueModel) && property_name == null) ||
                (!(subject is IValueModel) && property_name !=null)) {

            var bind_model = get_bind_model (subject, property_name);
            if (bind_model == null) {
                bind_model = create_bind_model (subject, property_name);
            }
            // FIXME: debug ("returning get or create bindmodel /w model as null: %s", (bind_model == null).to_string ());
            return bind_model;
        }

        private BindKey? resolve_bind_key (Object subject, string? property_name = null) {

            BindKey result = null;

            if (subject is AspectAdapter) {
                property_name = (subject as AspectAdapter).property_name;
            } else if (subject is IValueModel) {
                property_name = IValueModel.PROP_NAME;
            }

            if (property_name != null) {
                result = new BindKey (subject, property_name);
            }
            return result;
        }

        private Object? resolve_path (Object subject, ref string? prop_name) {
            var result = subject;
            // FIXME: Find a better solution to this.
            var is_layered_model = result is IAspectTrigger || result is AbstractModelHolder;

            while (is_layered_model) {
                if (result is IModelAdapter) {

                    // XXX: result = (result as IModelAdapter).value_model;
                    result = (result as IModelAdapter).get_model ();
                    // FIXME: remove it debug ("Value Model Type: %s", result.get_class ().get_type ().name ());

                    result = resolve_path (result, ref prop_name);
                }
                is_layered_model = result is IAspectTrigger || result is AbstractModelHolder;
            }

            return result;
        }
     }
}