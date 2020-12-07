# cython: language_level=3
# vim: set et ts=4 sw=4:

cdef extern from "graph_data.h" namespace "ara::graph":
    cdef cppclass GraphData:
        pass

cdef class PyGraphData:
    cdef GraphData _c_data
