cimport cgraph

from libcpp.string cimport string

cdef extern from "pass.h" namespace "pass":
    cdef cppclass Pass:
        Pass() except +
        string get_name()
        string get_description()
        void run(cgraph.Graph a)
