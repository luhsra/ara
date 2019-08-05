# vim: set et ts=4 sw=4:
# cython: language_level=3

cdef extern from "graph.h" namespace "ara::cfg":
    cdef cppclass ABBGraph:
        pass

cdef extern from "graph.h" namespace "ara::graph":
    cdef cppclass Graph:
        ABBGraph& abbs()
