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

    public class  SelectionInList<G> : AbstractValueHolder, IListModel<G> {
        /** Fields */
        private const int NO_SELECTION = -1;
        private IListModel<G> list_model;

        /** Properties */
        // if list holder changed the selection must be cleared.
        public IValueModel list_holder { get; set; }
        public IValueModel selection_holder { get; set; }
        public IValueModel selection_index_holder { get; set; }
        //public IValueModel selection_value_holder { get; set; }

        private int _selection_index = NO_SELECTION;
        public int selection_index {
            get {
               return _selection_index;
            }
            public set {
                if (NO_SELECTION <= value <= size) {
                    _selection_index = value;
                } else {
                    _selection_index = NO_SELECTION;
                }
                debug  ("Selection index is Set to %d", _selection_index);
                selection_index_holder.set_val (_selection_index);
                notify_property (IValueModel.PROP_NAME);
            }
        }

        public Value? selection {
            owned get {
                lock (selection_index) {
                    debug  ("selection: index_of: %d", selection_index);
                    selection_holder.set_val (getit (selection_index));
                    return selection_holder.get_val ();
                   }
            }
            set {
                lock (selection_index) {

                    selection_index = get_generic_selection_index (value);
                    debug  ("selection_index is Set to %d", selection_index);
                    base.set_val (value);
                }
              }
        }

        /** setter/getter methods*/
        public override Value? get_val () {
            return selection;
        }

        public override void set_val (Value? new_value) {
            selection = new_value;
        }

        /** Constrictor(s) */
        public SelectionInList.with_list_model (IListModel<G> list_model) {

            this.list_model = list_model;
            this.list_model.list_changed.connect ((size) => {
                debug  ("list_changed.... selection index %d size %d get_length () %d", selection_index, size, get_length ());
                if (selection_index >= size) {
                    selection_index = size -1;
                }
                this.list_changed (size);
            });
            this.list_model.item_changed.connect ((index, item) => {
                debug ("item_changed....");
                this.item_changed (index, item);
            });
            this.list_model.item_added.connect ((item) => {
                debug  ("Item added....");
                this.item_added (item);
            });

            this.list_model.item_removed.connect ((item) => {
                debug  ("Item removed....");
                this.item_removed (item);
            });


            this.list_holder =  new ValueHolder ();
            this.list_holder.set_val (list_model);
            this.list_holder.notify[IValueModel.PROP_NAME].connect (() => {
                debug  ("selection is.changed");
                   selection = null;
               });

            this.selection_holder =  new ValueHolder ();

            this.selection_index_holder = new ValueHolder (this.selection_index);
            this.selection_index_holder.notify[IValueModel.PROP_NAME].connect (() => {
                _selection_index = (int) selection_index_holder.get_val ();
                notify_property(IValueModel.PROP_NAME);
            });

            this.selection_index = NO_SELECTION;
        }

        public bool has_selection {
            get { return selection_index != NO_SELECTION; }
            private set {}
        }

        private Value? get_generic_selection_value (int selection_index) {

            Type type = typeof (G);
            debug  ("sin: get_generic_selection_value: %d, and size: %d", selection_index, list_model.get_length ());

            if (selection_index == NO_SELECTION || list_model.get_length () == 0) {
                return null;
            }

            /** if the Value is Value Type */
            Value? result = null;

            if (type.is_object()) {
                // BUG: The generic type is not supported as type cast.
                // return ((IListModel<G>) list_model).get (selection_index);

                Value? retval = Value (typeof (Object));
                retval = ((IListModel<Object>) list_model).get_at (selection_index);
                result = retval;
            } else {
                switch (type.name ()) {
                    case "gint":
                        result = ((IListModel<int>) list_model).get_at (selection_index);
                        break;
                    case "guint":
                        result = ((IListModel<uint>) list_model).get_at (selection_index);
                        break;
                    case "gchararray":
                        result = ((IListModel<string>) list_model).get_at (selection_index);
                        stdout.printf ("Gchararray Index: \"%s\"\n", result.get_string ());
                        break;
                    default:
                        error ("Value type \"%s\" is currently not supported\n", type.name());
                }
            }
            item_changed (selection_index, result);
            return result;
        }

        private int get_generic_selection_index (Value? value) {

            int result = NO_SELECTION;

            if (value == null) {
                return result;
            }

            Type type = typeof (G);

            if (type.is_object ()) {
                var object = (Object?) value;
                if (object != null) {
                    result = ((IListModel<G>) list_model).index_of (object);
                }

            } else {
                switch (type.name ()) {
                    case "gint":
                        result = ((IListModel<G>) list_model).index_of ((int) value);
                        break;
                    case "guint":
                        result = ((IListModel<G>) list_model).index_of ((uint) value);
                        break;
                    case "gchararray":
                        result = ((IListModel<G>) list_model).index_of ((string) value);
                        break;
                    default:
                        break;
                }
            }
            return result;
        }

        public new int size {
            get { return get_list_model_size (list_model); }
        }

        private int get_list_model_size (G list_model) {
            return ((IListModel<G>) list_model).get_length ();
        }

        public new int index_of (G? item) {
            return list_model.index_of (item);
        }

        public Value? getit (int index) {
            return get_generic_selection_value (index);
        }

        public void clear_selection () {
            selection_index = NO_SELECTION;
        }

        public G? get_at (int index) {
            return list_model.get_at (index);

        }

        public void set_at (int index, G value)
            requires (index >= 0 && index < size) {

            if (get_at (index) != value) {
                list_model.set_at (index, value);
                list_model.item_changed (index, value);
            }
        }

        public bool add (G item) {
            // BUG/FEATURE: Vala: return delegate_change (base.add, (DelegateSignal) item_added, item);
            bool result = list_model.add (item);

            if (result == true) {
                list_model.item_added (list_model.get_length ());
            }
            return result;
        }

        public bool add_all (Collection<G> items) {
            bool result = list_model.add_all (items);
            if (result == true) {
                foreach (var item in items) {
                    list_model.item_added (list_model.index_of(item));
                }
            }
            return result;
        }


        public void insert (int index, G item) {
            list_model.insert (index, item);
           // list_model.item_changed (index, item);
        }

        public bool remove (G item) {
           //BUG: Value: return delegate_change (base.remove, (DelegateSignal) item_removed, item);
            var index = list_model.index_of (item);
            bool result = list_model.remove (item);


            if (result == true) {
                //list_model.item_removed (index);
            }
            return result;
        }

        public G? remove_at (int index) {
            if (NO_SELECTION < index < get_length ()) {
                return list_model.remove_at (index);
            } else {
                return null;
            }
           // return result;
        }

        public void clear () {

            //foreach (var item in list_model) {
                //list_model.item_removed (item);
            //}
            list_model.clear ();
        }

        public int get_length () {
            return list_model.get_length ();
        }
    }
 }
