#cython: language_level=3

cdef extern from "graph.h" namespace "ara::cfg":
    cdef cppclass CFType:
        pass

cdef extern from "graph.h" namespace "ara::cfg::CFType":
    cdef CFType lcf
    cdef CFType icf
    cdef CFType gcf
