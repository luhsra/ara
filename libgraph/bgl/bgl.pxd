# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp.memory cimport shared_ptr

cimport bgl_wrapper

cdef class SubTypeMaker:
    cdef type n_type

cdef class Vertex(SubTypeMaker):
    cdef shared_ptr[bgl_wrapper.VertexWrapper] _c_vertex

cdef class Edge(SubTypeMaker):
    cdef shared_ptr[bgl_wrapper.EdgeWrapper] _c_edge

cdef class Graph(SubTypeMaker):
    cdef shared_ptr[bgl_wrapper.GraphWrapper] _c_graph
