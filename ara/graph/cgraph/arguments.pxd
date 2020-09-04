# cython: language_level=3
# vim: set et ts=4 sw=4:

from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from libcpp.vector cimport vector

cdef extern from "arguments.h" namespace "ara::graph":
    cdef cppclass CallPath:
        pass

    cdef cppclass Argument:
        bool is_determined()
        bool is_constant()

    cdef cppclass Arguments:
        ctypedef vector[shared_ptr[Argument]].size_type size_type

        @staticmethod
        shared_ptr[Arguments] get()

        size_type size()
        shared_ptr[Argument] at(size_type)
