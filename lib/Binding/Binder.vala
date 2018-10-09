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

namespace Daf.Core.Binding {

    /**
     * The Bindings bind two Objects property or ValueHolders.
     * It applies two-way bindings (one-way should be implemented later) /w
     * initial notify
     * It also can checks cyclical dependency error before the bindings applied.
     *
     * The cyclical dependency checks is very limited as:
     * = It cannot detect dependency error between two Binders' instance e.g.
     *   binder1.bind (a).to (b) -> binder2.bind (b).to (a) # Loop...
     * Solution: should be IoC container compliant means only one instance in an app
     *
     * = AspectAdapter is not supported e.g.
     *  Bindkey is person1, "name" pair and the binding uses an
     *  AspectAdapter to wrap the person1 object /w "name" property.
     *  var aa = new AspectAdapter (person1, "name");
     *  binder.bind (aa).to (person1, "name");
     *  This issue is not detectable due aa has different key for the same binding.
     *
     * = BufferedValueHolder is not supported as it implements a model_channel means
     *  the ValueModel can be swapped under the BufferedValueHolder so unbind () will lost
     *  the reference of it e.g:
     *  var ab = new AspectAdapter (person2, "name");
     *  var bvh = new BufferedValueHolder (aa);
     *  binder.bind (bvh). to (aa); # aa wrap person1, "name" see above
     *  bvh.set_model (aa); # means undetectable infinite loop.
     *
     *  To detect infinite loops set the G_.changed_MESSAGES=all env variable during tests as
     *  there's a debug () function in the on_notify_method ()
     **/
    public class Binder : Object, IBinder {
        public IBindModelRepository repository { private get;  set; }
        public IBindModelService service { private get;  set; }

        construct {
            _repository = new DefaultBindModelRepository ();
            var model_factory = new BindModelFactory ();
             _service = new BindModelService<BindKey, IBindModel> (_repository, model_factory);
        }

        /*
         * Should be IoC container compliant
         */
        public Binder () {
        }

        public IBindTo bind (Object subject, string? property_name = null) {
           return (IBindTo) service.get_or_create_bind_model (subject, property_name);
        }

        public IBindFrom unbind (Object subject, string? property_name = null) {
            return (IBindFrom) service.get_bind_model (subject, property_name);
        }
    }
}