# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "step.h" namespace "step":
    cdef cppclass Step:
        Step() except +
        void set_logger(object logger)
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void apply_config(dict config)
        void run(cgraph.Graph g)
