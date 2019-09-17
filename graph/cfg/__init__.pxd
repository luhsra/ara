# vim: set et ts=4 sw=4:
# cython: language_level=3

from libcpp.utility cimport pair
from libcpp.string cimport string
from libcpp cimport bool

cimport cfg.abbtype
cimport cfg.cftype

cdef extern from "graph.h" namespace "ara::cfg":
    cdef cppclass FunctionDescriptor:
        pass

    cdef cppclass Function:
        string name
        bool implemented
        bool syscall

    cdef cppclass ABB:
        string name
        cfg.abbtype.ABBType type

        string get_call()
        bool is_indirect()

    cdef cppclass ABBEdge:
        cfg.cftype.CFType type

    cdef cppclass ABBGraph:
        cppclass vertex_descriptor:
            pass

        const FunctionDescriptor& get_subgraph(const ABBGraph.vertex_descriptor)
