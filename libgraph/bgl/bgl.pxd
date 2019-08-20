# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp.memory cimport unique_ptr

cimport bgl_wrapper

cdef class Vertex:
    cdef unique_ptr[bgl_wrapper.VertexWrapper] _c_vertex

cdef class Edge:
    cdef unique_ptr[bgl_wrapper.EdgeWrapper] _c_edge

cdef class Graph:
    cdef unique_ptr[bgl_wrapper.GraphWrapper] _c_graph
