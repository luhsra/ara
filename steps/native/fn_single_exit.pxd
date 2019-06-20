cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "fn_single_exit.h" namespace "step":
    cdef cppclass FnSingleExit:
        FnSingleExit(dict config) except +
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
