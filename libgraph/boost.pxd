# cython: language_level=3

from libcpp.utility cimport pair

# note that boost graph stuff is of course not defined in graph.h but always
# included from that, so use that instead of the concrete boost header
cdef extern from "graph.h" namespace "boost":
    cdef cppclass iterator_range[I]:
        I begin()
        I end()

    iterator_range[I] make_iterator_range[I](I begin, I end)
