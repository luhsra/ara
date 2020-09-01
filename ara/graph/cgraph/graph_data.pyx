# cython: language_level=3
# vim: set et ts=4 sw=4:

from .graph_data cimport PyGraphData

from .arguments cimport Argument as CArgument, Arguments as CArguments

from libcpp.memory cimport unique_ptr, shared_ptr

cdef class Argument:
    cdef shared_ptr[CArgument] _c_argument

cdef class Arguments:
    cdef unique_ptr[CArguments] _c_arguments
