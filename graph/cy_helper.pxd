# distutils: language = c++
# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp.memory cimport shared_ptr
from libcpp cimport bool

cimport bgl_wrapper
cimport cfg

cdef extern from "cy_helper.h" namespace "ara::graph::cy_helper":
    cdef cppclass BGLExtensions:

        @staticmethod
        const shared_ptr[bgl_wrapper.GraphWrapper] get_subgraph(const cfg.ABBGraph&, const shared_ptr[bgl_wrapper.VertexWrapper])

    shared_ptr[bgl_wrapper.GraphWrapper] create_graph(bool, bool)


