cimport cgraph
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string

cdef extern from "warning.h":
    cdef cppclass Warning:
        shared_ptr[cgraph.ABB] warning_position

        string get_type()
