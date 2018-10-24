cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "step.h" namespace "step":
    cdef cppclass Step:
        Step(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
