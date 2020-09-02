# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp cimport bool

cdef extern from "arguments.h" namespace "ara::graph":
    cdef cppclass CallPath:
        pass

    cdef cppclass Argument:
        bool is_determined()
        bool is_constant()

    cdef cppclass Arguments:
        pass
