# vim: set et ts=4 sw=4:
# cython: language_level=3

from libcpp.utility cimport pair
from libcpp.string cimport string

cdef extern from "graph.h" namespace "ara::cfg":
    cdef cppclass ChildrenIterator:
        pass

    cdef cppclass FunctionDescriptor:
        pass

    cdef cppclass Function:
        string name

    cdef cppclass ABB:
        string name

    cdef cppclass ABBGraph:
        pair[ChildrenIterator, ChildrenIterator] children()

        ABB& operator[](unsigned long int)

        ctypedef ptrdiff_t difference_type

        cppclass edge_descriptor:
            pass

        cppclass edge_iterator:
            edge_descriptor& operator*()
            edge_iterator operator++()
            edge_iterator operator--()
            edge_iterator operator+(size_type)
            edge_iterator operator-(size_type)
            difference_type operator-(iterator)
            bint operator==(iterator)
            bint operator!=(iterator)
            bint operator<(iterator)
            bint operator>(iterator)
            bint operator<=(iterator)
            bint operator>=(iterator)

        cppclass vertex_iterator:
            unsigned long int& operator*()
            vertex_iterator operator++()
            vertex_iterator operator--()
            vertex_iterator operator+(size_type)
            vertex_iterator operator-(size_type)
            difference_type operator-(iterator)
            bint operator==(iterator)
            bint operator!=(iterator)
            bint operator<(iterator)
            bint operator>(iterator)
            bint operator<=(iterator)
            bint operator>=(iterator)

        cppclass children_iterator:
            pass


cdef extern from "graph.h" namespace "ara::graph":
    cdef cppclass Graph:
        ABBGraph& abbs()
