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

using Daf.UnitTest;

namespace Daf.Core.Test {

    static int main (string[] args) {

        GLib.Test.init (ref args);

        TestSuite.get_root ().add_suite (new ValueHolderTest ().get_suite ());
        TestSuite.get_root ().add_suite (new AspectAdapterTest ().get_suite ());
        TestSuite.get_root ().add_suite (new BufferedValueHolderTest ().get_suite ());
        TestSuite.get_root ().add_suite (new ModelPresenterTest ().get_suite ());
        TestSuite.get_root ().add_suite (new BindingsTest ().get_suite ());
        TestSuite.get_root ().add_suite (new AspectTriggerTest ().get_suite ());
        TestSuite.get_root ().add_suite (new TypeConverterTest ().get_suite ());
        TestSuite.get_root ().add_suite (new AspectTriggerTest ().get_suite ());
        TestSuite.get_root ().add_suite (new BindingsTest ().get_suite ());

        return GLib.Test.run ();
    }
}

