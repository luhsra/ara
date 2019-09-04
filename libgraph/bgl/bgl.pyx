# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

"""Generic python wrapper classes for the boost graph library."""

cimport bgl_wrapper as bgl_w
from common.move cimport move

from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as pp
from libcpp.memory cimport shared_ptr, unique_ptr
from libcpp.utility cimport pair
from libcpp cimport bool
from common.cy_helper cimport to_shared_ptr, to_string


cdef class SubTypeMaker:
    def __cinit__(self, n_type=None):
        self.n_type = n_type

    def gen(self, obj):
        if self.n_type:
            return self.n_type(copy=obj)
        return obj


cdef class EdgeIterator:
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.EdgeWrapper]] _iter
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.EdgeWrapper]] _end
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

    def __cinit__(self, edge_type=None, vertex_type=None):
        self.edge = SubTypeMaker(edge_type)
        self.vert = SubTypeMaker(vertex_type)

    def __iter__(self):
        return self

    def __next__(self):
        if deref(self._iter) == deref(self._end):
            raise StopIteration
        cdef shared_ptr[bgl_w.EdgeWrapper] e = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return self.edge.gen(edge_fac(e, self.edge.n_type, self.vert.n_type))


cdef make_edge_it(pair[unique_ptr[bgl_w.GraphIterator[bgl_w.EdgeWrapper]], unique_ptr[bgl_w.GraphIterator[bgl_w.EdgeWrapper]]] its, edge_type, vertex_type):
    it = EdgeIterator(edge_type, vertex_type)
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class VertexIterator:
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.VertexWrapper]] _iter
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.VertexWrapper]] _end
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

    def __cinit__(self, edge_type=None, vertex_type=None):
        self.edge = SubTypeMaker(edge_type)
        self.vert = SubTypeMaker(vertex_type)

    def __iter__(self):
        return self

    def __next__(self):
        if deref(self._iter) == deref(self._end):
            raise StopIteration
        cdef shared_ptr[bgl_w.VertexWrapper] v = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return self.vert.gen(vertex_fac(v, self.edge.n_type, self.vert.n_type))


cdef make_vertex_it(pair[unique_ptr[bgl_w.GraphIterator[bgl_w.VertexWrapper]], unique_ptr[bgl_w.GraphIterator[bgl_w.VertexWrapper]]] its, edge_type, vertex_type):
    it = VertexIterator(edge_type, vertex_type)
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class GraphIterator:
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.GraphWrapper]] _iter
    cdef shared_ptr[bgl_w.GraphIterator[bgl_w.GraphWrapper]] _end
    cdef SubTypeMaker graph
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

    def __cinit__(self, graph_type=None, edge_type=None, vertex_type=None):
        self.graph = SubTypeMaker(graph_type)
        self.edge = SubTypeMaker(edge_type)
        self.vert = SubTypeMaker(vertex_type)

    def __iter__(self):
        return self

    def __next__(self):
        if deref(self._iter) == deref(self._end):
            raise StopIteration
        cdef shared_ptr[bgl_w.GraphWrapper] e = to_shared_ptr(deref(deref(self._iter)))
        pp(deref(self._iter))
        return self.graph.gen(graph_fac(e, self.graph.n_type, self.edge.n_type, self.vert.n_type))


cdef make_graph_it(pair[unique_ptr[bgl_w.GraphIterator[bgl_w.GraphWrapper]], unique_ptr[bgl_w.GraphIterator[bgl_w.GraphWrapper]]] its, graph_type, edge_type, vertex_type):
    it = GraphIterator(graph_type, edge_type, vertex_type)
    it._iter = to_shared_ptr(move(its.first))
    it._end = to_shared_ptr(move(its.second))
    return it


cdef class Vertex:
    def __cinit__(self, edge_type=None, vertex_type=None, Vertex copy=None):
        if copy:
            self._c_vertex = copy._c_vertex
            self.edge = copy.vert
            self.vert = copy.edge
        else:
            self.edge = SubTypeMaker(edge_type)
            self.vert = SubTypeMaker(vertex_type)

    def __hash__(self):
        return deref(self._c_vertex).get_id()

    def __eq__(self, other):
        cdef Vertex o
        if isinstance(other, Vertex):
            o = other
            return deref(self._c_vertex).get_id() == deref(o._c_vertex).get_id()
        return False

    def __str__(self):
        vid = to_string(deref(self._c_vertex).get_id()).decode('utf-8')
        return f"Vertex({vid})"

    def in_edges(self):
        return make_edge_it(deref(self._c_vertex).in_edges(), self.edge.n_type, self.vert.n_type)

    def out_edges(self):
        return make_edge_it(deref(self._c_vertex).out_edges(), self.edge.n_type, self.vert.n_type)

    def in_degree(self):
        return deref(self._c_vertex).in_degree()

    def out_degree(self):
        return deref(self._c_vertex).out_degree()

    def degree(self):
        return deref(self._c_vertex).degree()

    def adjacent_vertices(self):
        return make_vertex_it(deref(self._c_vertex).adjacent_vertices(), self.edge.n_type, self.vert.n_type)

    def inv_adjacent_vertices(self):
        return make_vertex_it(deref(self._c_vertex).inv_adjacent_vertices(), self.edge.n_type, self.vert.n_type)

    def clear_in_edges(self):
        deref(self._c_vertex).clear_in_edges()

    def clear_out_edges(self):
        deref(self._c_vertex).clear_out_edges()

    def clear_edges(self):
        deref(self._c_vertex).clear_edges()

cdef vertex_fac(shared_ptr[bgl_w.VertexWrapper] v, edge_type, vertex_type):
    vert = Vertex(edge_type, vertex_type)
    vert._c_vertex = v
    return vert

cdef class Edge:
    def __cinit__(self, edge_type=None, vertex_type=None, Edge copy=None):
        if copy:
            self._c_edge = copy._c_edge
            self.edge = copy.vert
            self.vert = copy.edge
        else:
            self.edge = SubTypeMaker(edge_type)
            self.vert = SubTypeMaker(vertex_type)

    def source(self):
        return self.vert.gen(vertex_fac(to_shared_ptr(deref(self._c_edge).source()), self.edge.n_type, self.vert.n_type))

    def target(self):
        return self.vert.gen(vertex_fac(to_shared_ptr(deref(self._c_edge).target()), self.edge.n_type, self.vert.n_type))

cdef edge_fac(shared_ptr[bgl_w.EdgeWrapper] e, edge_type, vertex_type):
    edge = Edge(edge_type, vertex_type)
    edge._c_edge = e
    return edge

cdef class Graph:
    def __cinit__(self, graph_type=None, edge_type=None, vertex_type=None,
                  Graph copy=None):
        if copy:
            self._c_graph = copy._c_graph
            self.graph = copy.graph
            self.edge = copy.edge
            self.vert = copy.vert
        else:
            self.graph = SubTypeMaker(graph_type)
            self.edge = SubTypeMaker(edge_type)
            self.vert = SubTypeMaker(vertex_type)

    def vertices(self):
        return make_vertex_it(deref(self._c_graph).vertices(), self.edge.n_type, self.vert.n_type)

    def num_vertices(self):
        return deref(self._c_graph).num_vertices()

    def edges(self):
        return make_edge_it(deref(self._c_graph).edges(), self.edge.n_type, self.vert.n_type)

    def num_edges(self):
        return deref(self._c_graph).num_edges()

    def add_vertex(self):
        return self.vert.gen(vertex_fac(to_shared_ptr(deref(self._c_graph).add_vertex()), self.edge.n_type, self.vert.n_type))

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
        return self.gen_graph(graph_fac(to_shared_ptr(deref(self._c_graph).create_subgraph()), self.graph.n_type, self.edge.n_type, self.vert.n_type))

    def is_root(self):
        return deref(self._c_graph).is_root()

    def root(self):
        return self.gen_graph(graph_fac(to_shared_ptr(deref(self._c_graph).root())), self.graph.n_type, self.edge.n_type, self.vert.n_type)

    def parent(self):
        return self.gen_graph(graph_fac(to_shared_ptr(deref(self._c_graph).parent()), self.graph.n_type, self.edge.n_type, self.vert.n_type))

    def children(self):
        return make_graph_it(deref(self._c_graph).children(), self.graph.n_type, self.edge.n_type, self.vert.n_type)

    def local_to_global(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return self.edge.gen(edge_fac(to_shared_ptr(deref(self._c_graph).local_to_global(deref(e._c_edge))), self.edge.n_type, self.vert.n_type))
        if isinstance(obj, Vertex):
            v = obj
            return self.vert.gen(vertex_fac(to_shared_ptr(deref(self._c_graph).local_to_global(deref(v._c_vertex))), self.edge.n_type, self.vert.n_type))
        assert False

    def global_to_local(self, obj):
        cdef Edge e
        cdef Vertex v
        if isinstance(obj, Edge):
            e = obj
            return self.edge.gen(edge_fac(to_shared_ptr(deref(self._c_graph).global_to_local(deref(e._c_edge))), self.edge.n_type, self.vert.n_type))
        if isinstance(obj, Vertex):
            v = obj
            return self.vert.gen(vertex_fac(to_shared_ptr(deref(self._c_graph).global_to_local(deref(v._c_vertex))), self.edge.n_type, self.vert.n_type))
        assert False

    def find_vertex(self, Vertex vertex):
        cdef pair[unique_ptr[bgl_w.VertexWrapper], bool] ret = deref(self._c_graph).find_vertex(deref(vertex._c_vertex))
        if ret.second:
            return self.vert.gen(vertex_fac(to_shared_ptr(move(ret.first)), self.edge.n_type, self.vert.n_type))
        return None

    def find_edge(self, Edge edge):
        cdef pair[unique_ptr[bgl_w.EdgeWrapper], bool] ret = deref(self._c_graph).find_edge(deref(edge._c_edge))
        if ret.second:
            return self.edge.gen(edge_fac(to_shared_ptr(move(ret.first)), self.edge.n_type, self.vert.n_type))
        return None

    def filter_by(self, vertex=None, edge=None):
        pass

cdef graph_fac(shared_ptr[bgl_w.GraphWrapper] g, graph_type=None, edge_type=None, vertex_type=None):
    graph = Graph(graph_type, edge_type, vertex_type)
    graph._c_graph = g
    return graph
