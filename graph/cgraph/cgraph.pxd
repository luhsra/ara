# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport llvm

from libcpp.memory cimport unique_ptr

cdef extern from "graph.h" namespace "ara::graph":
    cdef cppclass Graph:
        Graph()
        Graph(object, unique_ptr[llvm.Module])
