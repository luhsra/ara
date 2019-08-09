#cython: language_level=3

cdef extern from "graph.h" namespace "ara::cfg":
    cdef cppclass ABBType:
        pass

cdef extern from "graph.h" namespace "ara::cfg::ABBType":
    cdef ABBType syscall
    cdef ABBType call
    cdef ABBType computation
