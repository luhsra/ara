# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp.memory cimport shared_ptr

cimport bgl_wrapper

cdef class SubTypeMaker:
    cdef object n_type

cdef class Vertex:
    cdef shared_ptr[bgl_wrapper.VertexWrapper] _c_vertex
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

cdef class Edge:
    cdef shared_ptr[bgl_wrapper.EdgeWrapper] _c_edge
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

cdef class Graph:
    cdef shared_ptr[bgl_wrapper.GraphWrapper] _c_graph
    cdef SubTypeMaker root_graph
    cdef SubTypeMaker graph
    cdef SubTypeMaker vert
    cdef SubTypeMaker edge

cdef graph_fac(shared_ptr[bgl_wrapper.GraphWrapper] g,
               root_graph_type, graph_type, edge_type, vertex_type)
