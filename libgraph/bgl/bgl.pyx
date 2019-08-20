# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport bgl_wrapper as bgl
from move cimport move

from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as pp
from libcpp.memory cimport shared_ptr, unique_ptr
from libcpp.utility cimport pair
from common.cy_helper cimport to_shared_ptr

cdef class EdgeIterator:
    cdef shared_ptr[bgl.GraphIterator[bgl.EdgeWrapper]] _iter
    cdef shared_ptr[bgl.GraphIterator[bgl.EdgeWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef shared_ptr[bgl.EdgeWrapper] e = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return edge_fac(e)


cdef make_edge_it(pair[unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]], unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]]] its):
    it = EdgeIterator()
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class VertexIterator:
    cdef shared_ptr[bgl.GraphIterator[bgl.VertexWrapper]] _iter
    cdef shared_ptr[bgl.GraphIterator[bgl.VertexWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef shared_ptr[bgl.VertexWrapper] v = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return vertex_fac(v)


cdef make_vertex_it(pair[unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]], unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]]] its):
    it = VertexIterator()
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class GraphIterator:
    cdef shared_ptr[bgl.GraphIterator[bgl.GraphWrapper]] _iter
    cdef shared_ptr[bgl.GraphIterator[bgl.GraphWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef shared_ptr[bgl.GraphWrapper] e = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return graph_fac(e)


cdef make_graph_it(pair[unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]], unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]]] its):
    it = GraphIterator()
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class Vertex:
    def in_edges(self):
        return make_edge_it(deref(self._c_vertex).in_edges())

    def out_edges(self):
        return make_edge_it(deref(self._c_vertex).out_edges())

    def in_degree(self):
        return deref(self._c_vertex).in_degree()

    def out_degree(self):
        return deref(self._c_vertex).out_degree()

    def degree(self):
        return deref(self._c_vertex).degree()

    def adjacent_vertices(self):
        return make_vertex_it(deref(self._c_vertex).adjacent_vertices())

    def inv_adjacent_vertices(self):
        return make_vertex_it(deref(self._c_vertex).inv_adjacent_vertices())

    def clear_in_edges(self):
        deref(self._c_vertex).clear_in_edges()

    def clear_out_edges(self):
        deref(self._c_vertex).clear_out_edges()

    def clear_edges(self):
        deref(self._c_vertex).clear_edges()

cdef vertex_fac(shared_ptr[bgl_wrapper.VertexWrapper] v):
    vert = Vertex()
    vert._c_vertex = v
    return vert

cdef class Edge:
    def source(self):
        return vertex_fac(to_shared_ptr(deref(self._c_edge).source()))

    def target(self):
        return vertex_fac(to_shared_ptr(deref(self._c_edge).target()))

cdef edge_fac(shared_ptr[bgl_wrapper.EdgeWrapper] e):
    edge = Edge()
    edge._c_edge = e
    return edge

cdef class Graph:
    def vertices(self):
        return make_vertex_it(deref(self._c_graph).vertices())

    def num_vertices(self):
        return deref(self._c_graph).num_vertices()

    def edges(self):
        return make_edge_it(deref(self._c_graph).edges())

    def num_edges(self):
        return deref(self._c_graph).num_edges()

    def add_vertex(self):
        return vertex_fac(to_shared_ptr(deref(self._c_graph).add_vertex()))

    # TODO not supported by boost subgraph
    # def remove_vertex(self, vertex):
    #     cdef Vertex v = vertex
    #     deref(self._c_graph).remove_vertex(deref(v.vertex))

    def add_edge(self, source, target):
        cdef Vertex s = source
        cdef Vertex t = target
        deref(self._c_graph).add_edge(deref(s._c_vertex), deref(t._c_vertex))

    def remove_edge(self, edge):
        cdef Edge e = edge
        deref(self._c_graph).remove_edge(deref(e._c_edge))

    # subgraph functions
    def create_subgraph(self):
        return graph_fac(to_shared_ptr(deref(self._c_graph).create_subgraph()))

    def is_root(self):
        return deref(self._c_graph).is_root()

    def root(self):
        return graph_fac(to_shared_ptr(deref(self._c_graph).root()))

    def parent(self):
        return graph_fac(to_shared_ptr(deref(self._c_graph).parent()))

    def children(self):
        return make_graph_it(deref(self._c_graph).children())

    def local_to_global(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return edge_fac(to_shared_ptr(deref(self._c_graph).local_to_global(deref(e._c_edge))))
        if isinstance(obj, Vertex):
            v = obj
            return vertex_fac(to_shared_ptr(deref(self._c_graph).local_to_global(deref(v._c_vertex))))

    def global_to_local(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return edge_fac(to_shared_ptr(deref(self._c_graph).global_to_local(deref(e._c_edge))))
        if isinstance(obj, Vertex):
            v = obj
            return vertex_fac(to_shared_ptr(deref(self._c_graph).global_to_local(deref(v._c_vertex))))

    def filter_by(self, vertex=None, edge=None):
        pass

cdef graph_fac(shared_ptr[bgl_wrapper.GraphWrapper] g):
    graph = Graph()
    graph._c_graph = g
    return graph
