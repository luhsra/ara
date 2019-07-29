cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "step.h" namespace "step":
    cdef cppclass Option:
        string name
        string help

    cdef cppclass Step:
        Step(dict config) except +
        void set_logger(object logger)
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)
        vector[Option] config_help()

    Step* step_fac[T](dict)
