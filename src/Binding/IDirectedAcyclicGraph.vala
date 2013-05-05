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

    public errordomain DependencyGraphError {
        CYCLIC_DEPENDENCY
    }

    /**
     * This implements a Dependency graph resolution algorythm based on
     * Ferry's Boender python algorythm see details:
     * http://www.electricmonk.nl/docs/dependency_resolving_algorithm/dependency_resolving_algorithm.html
     **/
    public interface IDirectedAcyclicGraph : Object {

        public abstract unowned List<IDirectedAcyclicGraph> edges { get; construct set; }
        public abstract string name { get; set; }

        public void add_edge (IDirectedAcyclicGraph node) {
            edges.append (node);
        }

        public void remove_edge (IDirectedAcyclicGraph node) {
            edges.remove (node);
        }

        protected void resolve_dependency (IDirectedAcyclicGraph node,
                                            List<IDirectedAcyclicGraph> resolved,
                                            List<IDirectedAcyclicGraph> unresolved)
                                            throws DependencyGraphError {
            unresolved.append (node);

            foreach (IDirectedAcyclicGraph edge in node.edges) {

                if (resolved.index (edge) < 0) {
                    if (unresolved.index (edge) >= 0) {
                        // Circular reference error
                           throw new DependencyGraphError.CYCLIC_DEPENDENCY  ("A cyclic dependency detected.");
                    }
                    resolve_dependency (edge, resolved, unresolved);
                }
            }

            resolved.append (node);
            unresolved.remove (node);
        }

        public abstract void resolve (IDirectedAcyclicGraph node)
                                                        throws DependencyGraphError;
    }
}