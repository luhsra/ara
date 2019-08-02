# cython: language_level=3
cimport cgraph

cimport option

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool
from libc.stdint cimport int64_t

cdef extern from "step.h" namespace "step":
    cdef cppclass Step:
        Step() except +
        void set_logger(object logger)
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void apply_config(dict config)
        void run(cgraph.Graph a)

cdef extern from "cy_helper.h":
    Step* step_fac[T]()
    vector[option.Option*] repack(Step& step)

cdef extern from "cy_helper.h" namespace "ara::option":
    string get_type_args(option.Option*)
