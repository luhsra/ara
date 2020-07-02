# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.memory cimport unique_ptr

cdef extern from "step.h" namespace "ara::step":
    cdef cppclass Step:
        Step() except +
        void apply_config(dict config)
        void run() except +

    cdef cppclass StepFactory:
        string get_name()
        string get_description()
        unique_ptr[Step] instantiate(object, cgraph.Graph, object)
