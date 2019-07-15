# vim: set et ts=4 sw=4:
cimport cgraph
from libcpp.memory cimport shared_ptr

cdef class PyGraph:
    cdef shared_ptr[cgraph.Graph] _c_graph

cdef create_abb(shared_ptr[cgraph.ABB] abb)
