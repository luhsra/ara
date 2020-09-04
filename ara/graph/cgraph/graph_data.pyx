# cython: language_level=3
# vim: set et ts=4 sw=4:

from .graph_data cimport PyGraphData

from .arguments cimport Argument as CArgument, Arguments as CArguments
from common.cy_helper cimport to_string

from libcpp.memory cimport unique_ptr, shared_ptr
from cython.operator cimport dereference as deref

cdef class Argument:
    cdef shared_ptr[CArgument] _c_argument

    def is_determined(self):
        return deref(self._c_argument).is_determined()

    def is_constant(self):
        return deref(self._c_argument).is_constant()

    def __repr__(self):
        return to_string[CArgument](deref(self._c_argument)).decode('UTF-8')


cdef class Arguments:
    cdef shared_ptr[CArguments] _c_arguments

    def __cinit__(self, create=True):
        if create:
            self._c_arguments = CArguments.get()

    def __init__(self, create=True):
        pass

    def __repr__(self):
        return to_string[CArguments](deref(self._c_arguments)).decode('UTF-8')

    def __len__(self):
        return deref(self._c_arguments).size()

    def __getitem__(self, key):
        if (key >= len(self)):
            raise IndexError("Argument index out of range")
        cdef shared_ptr[CArgument] c_arg = deref(self._c_arguments).at(key)
        arg = Argument()
        arg._c_argument = c_arg
        return arg

    def __iter__(self):
        class ArgumentsIterator:
            def __init__(self, args):
                self._index = 0
                self._args = args

            def __next__(self):
                if len(self._args) == self._index:
                    raise StopIteration
                ret = self._args[self._index]
                self._index += 1
                return ret

        return ArgumentsIterator(self)


cdef public object py_get_arguments(shared_ptr[CArguments] c_args):
    args = Arguments(create=False);
    args._c_arguments = c_args
    return args
