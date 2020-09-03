# cython: language_level=3
# vim: set et ts=4 sw=4:

from .graph_data cimport PyGraphData

from .arguments cimport Argument as CArgument, Arguments as CArguments

from libcpp.memory cimport unique_ptr, shared_ptr
from cython.operator cimport dereference as deref

cdef class Argument:
    cdef shared_ptr[CArgument] _c_argument

    def is_determined(self):
        return deref(self._c_argument).is_determined()

    def is_constant(self):
        return deref(self._c_argument).is_constant()


cdef class Arguments:
    cdef shared_ptr[CArguments] _c_arguments

    def __cinit__(self, create=True):
        if create:
            self._c_arguments = CArguments.get()

    def __init__(self, create=True):
        pass


cdef public object py_get_arguments(shared_ptr[CArguments] c_args):
    args = Arguments(create=False);
    args._c_arguments = c_args
    return args
