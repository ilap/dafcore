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

    public abstract class AbstractAcyclicGraph : Object, IDirectedAcyclicGraph {

        public unowned List<IDirectedAcyclicGraph> edges { get; construct set; }
        public string name { get; set; }


        public List<IDirectedAcyclicGraph> resolved = new List<IDirectedAcyclicGraph> ();
        public List<IDirectedAcyclicGraph> unresolved = new List<IDirectedAcyclicGraph> ();

        construct {
            edges = new List<IDirectedAcyclicGraph> ();
        }

        public void resolve (IDirectedAcyclicGraph node)
            throws DependencyGraphError {
            resolve_dependency (node, resolved, unresolved);
        }
    }
}