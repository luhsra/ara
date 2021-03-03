# cython: language_level=3
# vim: set et ts=4 sw=4:

from graph_data cimport PyGraphData, CallPath

from carguments cimport Argument as CArgument, Arguments as CArguments, CallPath as CCallPath
from os cimport SysCall as CSysCall
from common.cy_helper cimport to_string
from cgraph cimport CallGraph, SigType as CSigType
from cy_helper cimport to_sigtype, safe_get_value

from libcpp.memory cimport unique_ptr, shared_ptr
from libcpp.vector cimport vector
from libcpp.string cimport string
from libcpp cimport bool
from cython.operator cimport dereference as deref, postincrement
from ir cimport Value, AttributeSet
from ara.os import get_syscalls, get_os_syscalls

# workaround for https://github.com/cython/cython/issues/3816
# from pyllco cimport get_obj_from_value
cdef extern from 'pyllco.h':
    object get_obj_from_value(Value&)
    object get_obj_from_attr_set(AttributeSet&)


cdef class CallPath:
    def __cinit__(self):
        pass

    def __repr__(self):
        return to_string[CCallPath](self._c_callpath).decode('UTF-8')

    def __hash__(self):
        return self._c_callpath.hash()

    def __eq__(self, CallPath other):
        return self._c_callpath == other._c_callpath

    def print(self, bool call_site=False,
              bool instruction=False,
              bool functions=False):
        return self._c_callpath.print(call_site,
                                      instruction,
                                      functions).decode('UTF-8')

    def add_call_site(self, call_graph, call_site):
        self._c_callpath.add_call_site(call_graph, call_site)

    def pop_front(self):
        self._c_callpath.pop_front()

    def pop_back(self):
        self._c_callpath.pop_back()

    def is_recursive(self):
        return self._c_callpath.is_recursive()

    def __copy__(self):
        cp = CallPath()
        # calls copy constructor in C++
        cp._c_callpath = self._c_callpath
        return cp

    def __len__(self):
        return self._c_callpath.size()

    def __getitem__(self, index):
        if (index >= len(self) or -index > len(self)):
            raise IndexError("Argument index out of range")
        if (index < 0):
            index = len(self) + index
        return self._c_callpath.py_at(index)


cdef enum _ArgumentIteratorKind:
    keys = 0,
    values = 1,
    both = 2


cdef class ArgumentIterator:
    cdef CArgument.iterator _c_iter
    cdef CArgument.iterator _c_iter_end
    cdef _ArgumentIteratorKind _kind

    def __cinit__(self, Argument arg, int kind):
        self._c_iter = deref(arg._c_argument).begin()
        self._c_iter_end = deref(arg._c_argument).end()
        self._kind = <_ArgumentIteratorKind> kind

    def __next__(self):
        if self._c_iter == self._c_iter_end:
            raise StopIteration
        cp = CallPath()
        cp._c_callpath = deref(self._c_iter).first
        val = get_obj_from_value(deref(self._c_iter).second)
        postincrement(self._c_iter);

        if self._kind == _ArgumentIteratorKind.keys:
            return cp
        if self._kind == _ArgumentIteratorKind.values:
            return val
        if self._kind == _ArgumentIteratorKind.both:
            return cp, val
        raise RuntimeError("Wrong type of kind")


cdef class Argument:
    cdef shared_ptr[CArgument] _c_argument

    def is_determined(self):
        return deref(self._c_argument).is_determined()

    def is_constant(self):
        return deref(self._c_argument).is_constant()

    def has_value(self, key: CallPath):
        return deref(self._c_argument).has_value(key._c_callpath)

    def get_value(self, CallPath key=CallPath(), raw=False):
        """Retrieve the value of the argument.

        Keyword arguments:
        key -- Retrieve value of a specific call path. Is set the the empty
               call path per default.
        raw -- Get raw LLVM value, if set. Tries to translate the LLVM value in
               a Python value otherwise.

        Can raise an IndexError, if no value at this key is found.
        Can raise an pyllco.InvalidValue, if the LLVM value cannot be
        interpreted.
        """
        cdef AttributeSet a_set
        value = safe_get_value(self._c_argument, key._c_callpath)
        if value is None:
            raise IndexError("Argument has no such value.")
        if raw:
            return value
        else:
            a_set = deref(self._c_argument).get_attrs()
            attrs = get_obj_from_attr_set(a_set)
            return value.get(attrs=attrs)

    def __repr__(self):
        return to_string[CArgument](deref(self._c_argument)).decode('UTF-8')

    def __len__(self):
        return deref(self._c_argument).size()

    def __bool__(self):
        return len(self) != 0

    def __getitem__(self, key):
        if key not in self:
            raise KeyError(key)
        return self.get_value(key)

    def __contains__(self, key):
        return self.has_value(key)

    def values(self):
        class ItemIterator:
            def __init__(self, arg):
                self._arg = arg

            def __iter__(self):
                return ArgumentIterator(self._arg,
                                        <int> _ArgumentIteratorKind.values)
        return ItemIterator(self)

    def items(self):
        class ItemIterator:
            def __init__(self, arg):
                self._arg = arg

            def __iter__(self):
                return ArgumentIterator(self._arg,
                                        <int> _ArgumentIteratorKind.both)
        return ItemIterator(self)

    def __iter__(self):
        return ArgumentIterator(self, <int> _ArgumentIteratorKind.keys)


cdef class Arguments:
    cdef shared_ptr[CArguments] _c_arguments

    cdef object make_arg(self, shared_ptr[CArgument] c_arg):
        if (c_arg == NULL):
            return None
        arg = Argument()
        arg._c_argument = c_arg
        return arg

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
        if (key >= len(self) or -key > len(self)):
            raise IndexError("Argument index out of range")
        if (key < 0):
            key = len(self) + key
        return self.make_arg(deref(self._c_arguments).at(key))

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

    def get_return_value(self):
        return self.make_arg(deref(self._c_arguments).get_return_value())


cdef public object py_get_arguments(shared_ptr[CArguments] c_args):
    args = Arguments(create=False);
    args._c_arguments = c_args
    return args


# functions for os.h
cdef vector[CSysCall] _get_syscalls(object iterator):
    cdef vector[CSysCall] syscalls
    for syscall, cls in iterator:
        sys_func = getattr(cls, syscall)
        syscalls.push_back(CSysCall(sys_func, cls))
    return syscalls


cdef public vector[CSysCall] py_get_syscalls():
    return _get_syscalls(get_syscalls())


cdef public string py_syscall_get_name(object syscall):
    return syscall.__name__.encode('UTF-8')


cdef public vector[CSigType] py_syscall_get_signature(object syscall):
    cdef vector[CSigType] signature
    cdef CSigType c_arg
    assert isinstance(syscall.signature, tuple), "Invalid Signature"
    for arg in syscall.signature:
        c_arg = to_sigtype(int(arg))
        signature.push_back(c_arg)
    return signature


cdef public string py_os_get_name(object os):
    return os.get_name().encode('UTF-8')


cdef public vector[CSysCall] py_os_get_syscalls(object os):
    return _get_syscalls(get_os_syscalls(os))
