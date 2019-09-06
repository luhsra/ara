# vim: set et ts=4 sw=4:
# cython: language_level=3

cimport cfg

cdef extern from "graph.h" namespace "ara::graph":
    cdef cppclass Graph:
        cfg.ABBGraph& abbs()
