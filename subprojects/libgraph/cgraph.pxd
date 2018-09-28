cdef extern from "graph.h" namespace "graph":
    cdef cppclass Graph:
        Graph() except +
