# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport bgl_wrapper as bgl
from move cimport move

from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as pp
from libcpp.memory cimport unique_ptr
from libcpp.utility cimport pair

cdef class EdgeIterator:
    cdef unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]] _iter
    cdef unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef unique_ptr[bgl.EdgeWrapper] e = deref(deref(self._iter))
        pp(deref(self._iter))
        return edge_fac(move(e))


cdef make_edge_it(pair[unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]], unique_ptr[bgl.GraphIterator[bgl.EdgeWrapper]]] its):
    it = EdgeIterator()
    it._iter = move(its.first)
    it._end = move(its.second)
    return it


cdef class VertexIterator:
    cdef unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]] _iter
    cdef unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef unique_ptr[bgl.VertexWrapper] e = deref(deref(self._iter))
        pp(deref(self._iter))
        return vertex_fac(move(e))


cdef make_vertex_it(pair[unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]], unique_ptr[bgl.GraphIterator[bgl.VertexWrapper]]] its):
    it = VertexIterator()
    it._iter = move(its.first)
    it._end = move(its.second)
    return it


cdef class GraphIterator:
    cdef unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]] _iter
    cdef unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]] _end

    def __iter__(self):
        return self

    def next(self):
        if self._iter == self._end:
            raise StopIteration
        cdef unique_ptr[bgl.GraphWrapper] e = deref(deref(self._iter))
        pp(deref(self._iter))
        return graph_fac(move(e))


cdef make_graph_it(pair[unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]], unique_ptr[bgl.GraphIterator[bgl.GraphWrapper]]] its):
    it = GraphIterator()
    it._iter = move(its.first)
    it._end = move(its.second)
    return it


cdef class Vertex:
    def in_edges(self):
        return make_edge_it(deref(self.vertex).in_edges())

    def out_edges(self):
        return make_edge_it(deref(self.vertex).out_edges())

    def in_degree(self):
        return deref(self.vertex).in_degree()

    def out_degree(self):
        return deref(self.vertex).out_degree()

    def degree(self):
        return deref(self.vertex).degree()

    def adjacent_vertices(self):
        return make_vertex_it(deref(self.vertex).adjacent_vertices())

    def inv_adjacent_vertices(self):
        return make_vertex_it(deref(self.vertex).inv_adjacent_vertices())

    def clear_in_edges(self):
        deref(self.vertex).clear_in_edges()

    def clear_out_edges(self):
        deref(self.vertex).clear_out_edges()

    def clear_edges(self):
        deref(self.vertex).clear_edges()

cdef vertex_fac(unique_ptr[bgl_wrapper.VertexWrapper] v):
    vert = Vertex()
    vert.vertex = move(v)
    return vert

cdef class Edge:
    def source(self):
        return vertex_fac(deref(self.edge).source())

    def target(self):
        return vertex_fac(deref(self.edge).target())

cdef edge_fac(unique_ptr[bgl_wrapper.EdgeWrapper] e):
    edge = Edge()
    edge.edge = move(e)
    return edge

cdef class Graph:
    def vertices(self):
        return make_vertex_it(deref(self.graph).vertices())

    def num_vertices(self):
        return deref(self.graph).num_vertices()

    def edges(self):
        return make_edge_it(deref(self.graph).edges())

    def num_edges(self):
        return deref(self.graph).num_edges()

    def add_vertex(self):
        return vertex_fac(deref(self.graph).add_vertex())

    # TODO not supported by boost subgraph
    # def remove_vertex(self, vertex):
    #     cdef Vertex v = vertex
    #     deref(self.graph).remove_vertex(deref(v.vertex))

    def add_edge(self, source, target):
        cdef Vertex s = source
        cdef Vertex t = target
        deref(self.graph).add_edge(deref(s.vertex), deref(t.vertex))

    def remove_edge(self, edge):
        cdef Edge e = edge
        deref(self.graph).remove_edge(deref(e.edge))

    # subgraph functions
    def create_subgraph(self):
        return graph_fac(deref(self.graph).create_subgraph())

    def is_root(self):
        return deref(self.graph).is_root()

    def root(self):
        return graph_fac(deref(self.graph).root())

    def parent(self):
        return graph_fac(deref(self.graph).parent())

    def children(self):
        return make_graph_it(deref(self.graph).children())

    def local_to_global(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return edge_fac(deref(self.graph).local_to_global(deref(e.edge)))
        if isinstance(obj, Vertex):
            v = obj
            return vertex_fac(deref(self.graph).local_to_global(deref(v.vertex)))

    def global_to_local(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return edge_fac(deref(self.graph).global_to_local(deref(e.edge)))
        if isinstance(obj, Vertex):
            v = obj
            return vertex_fac(deref(self.graph).global_to_local(deref(v.vertex)))

    def filter_by(self, vertex=None, edge=None):
        pass

cdef graph_fac(unique_ptr[bgl_wrapper.GraphWrapper] g):
    graph = Graph()
    graph.graph = move(g)
    return graph
