# vim: set et ts=4 sw=4:
# cython: language_level=3

from libcpp.utility cimport pair
from libcpp.string cimport string
from libcpp cimport bool

cimport cfg.abbtype

cdef extern from "graph.h" namespace "ara::cfg":
    # cdef cppclass FunctionDescriptor:
    #     pass

    # cdef cppclass Function:
    #     string name
    #     bool implemented

    # cdef cppclass ABB:
    #     string name
    #     cfg.abbtype.ABBType type

    #     string get_call()
    #     bool is_indirect()

    cdef cppclass ABBGraph:
        pass
        # cppclass children_iterator:
        #     pass

        # pair[ABBGraph.children_iterator, ABBGraph.children_iterator] children()

        # ABB& operator[](unsigned long int)

        # ctypedef ptrdiff_t difference_type

        # cppclass edge_descriptor:
        #     pass

        # cppclass edge_iterator:
        #     edge_descriptor& operator*()
        #     edge_iterator operator++()
        #     edge_iterator operator--()
        #     edge_iterator operator+(size_type)
        #     edge_iterator operator-(size_type)
        #     difference_type operator-(iterator)
        #     bint operator==(iterator)
        #     bint operator!=(iterator)
        #     bint operator<(iterator)
        #     bint operator>(iterator)
        #     bint operator<=(iterator)
        #     bint operator>=(iterator)

        # cppclass vertex_iterator:
        #     unsigned long int& operator*()
        #     vertex_iterator operator++()
        #     vertex_iterator operator--()
        #     vertex_iterator operator+(size_type)
        #     vertex_iterator operator-(size_type)
        #     difference_type operator-(iterator)
        #     bint operator==(iterator)
        #     bint operator!=(iterator)
        #     bint operator<(iterator)
        #     bint operator>(iterator)
        #     bint operator<=(iterator)
        #     bint operator>=(iterator)
