# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph
cimport cstep
cimport option

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr

cdef extern from "cy_helper.h" namespace "ara::step":
    unique_ptr[cstep.StepFactory] make_step_fac[T]()
    vector[const option.Option*] repack(cstep.StepFactory& step)
    string get_dependencies(cstep.Step&, string)

cdef extern from "cy_helper.h" namespace "ara::option":
    string get_type_args(const option.Option*)
