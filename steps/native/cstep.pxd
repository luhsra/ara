cimport cgraph

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "step.h" namespace "step":
    cdef cppclass Step:
        Step(dict config) except +
        void set_logger(object logger)
        string get_name()
        string get_description()
        vector[string] get_dependencies()
        void run(cgraph.Graph a)

    Step* step_fac[T](dict)
