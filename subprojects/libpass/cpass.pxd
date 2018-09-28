cimport cgraph
from libcpp.vector cimport vector
from libcpp.string cimport string

cdef extern from "pass.h" namespace "pass":
    cdef cppclass Pass:
        Pass() except +
        void run(cgraph.Graph a, vector[string] files)
