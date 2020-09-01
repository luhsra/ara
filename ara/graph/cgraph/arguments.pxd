# cython: language_level=3
# vim: set et ts=4 sw=4:

cdef extern from "arguments.h" namespace "ara::graph":
    cdef cppclass CallPath:
        pass

    cdef cppclass Argument:
        pass

    cdef cppclass Arguments:
        pass
