# cython: language_level=3
cimport cgraph

cimport option

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport int64_t

cdef extern from "step.h" namespace "step":
    cdef cppclass Step:
        Step(dict config) except +
        void set_logger(object logger)
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

cdef extern from "cy_helper.h":
    Step* step_fac[T](dict)
    vector[option.Option*] repack(Step& step)

cdef extern from "cy_helper.h" namespace "ara::option":
    bool get_range_arguments(option.Option*, int64_t&, int64_t&)
    bool get_range_arguments(option.Option*, double&, double&)
