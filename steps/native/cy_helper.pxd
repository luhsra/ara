# cython: language_level=3
# vim: set et ts=4 sw=4:

cimport cgraph
cimport cstep
cimport option
cimport llvm

from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr

cdef extern from "cy_helper.h" namespace "ara::step":
    cstep.Step* step_fac[T]()
    vector[option.Option*] repack(cstep.Step& step)

cdef extern from "cy_helper.h" namespace "ara::option":
    string get_type_args(option.Option*)
