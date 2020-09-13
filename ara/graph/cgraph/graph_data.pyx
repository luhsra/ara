# cython: language_level=3
# vim: set et ts=4 sw=4:

from .graph_data cimport PyGraphData

from .arguments cimport Argument as CArgument, Arguments as CArguments
from .arguments cimport CallPath as CCallPath
from common.cy_helper cimport to_string
from .cgraph cimport CallGraph

from libcpp.memory cimport unique_ptr, shared_ptr
from libcpp cimport bool
from cython.operator cimport dereference as deref, postincrement
from ir cimport Value

# workaround for https://github.com/cython/cython/issues/3816
# from pyllco cimport get_obj_from_value
cdef extern from 'pyllco.h':
    object get_obj_from_value(Value&)


cdef class CallPath:
    cdef CCallPath _c_callpath

    def __cinit__(self):
        pass

    def __repr__(self):
        return to_string[CCallPath](self._c_callpath).decode('UTF-8')

    def __hash__(self):
        return self._c_callpath.hash()

    def __eq__(self, CallPath other):
        return self._c_callpath == other._c_callpath

    def print(self, call_graph,
              bool call_site=False,
              bool instruction=False,
              bool functions=False):
        assert hasattr(call_graph, "_Graph__graph"), "call_graph is not a graph tool graph."
        return self._c_callpath.print(CallGraph.get(call_graph),
                                      call_site,
                                      instruction,
                                      functions).decode('UTF-8')

    def add_call_site(self, call_graph, call_site):
        self._c_callpath.add_call_site(
            call_site,
            call_graph.ep.callsite_name[call_site].encode('UTF-8')
        )

    def pop_front(self):
        self._c_callpath.pop_front()

    def pop_back(self):
        self._c_callpath.pop_back()

    def __copy__(self):
        cp = CallPath()
        # calls copy constructor in C++
        cp._c_callpath = self._c_callpath
        return cp

    def __len__(self):
        return self._c_callpath.size()

    def get_call_site(self, call_graph, index):
        assert hasattr(call_graph, "_Graph__graph"), "call_graph is not a graph tool graph."
        return self._c_callpath.get_call_site(call_graph, index)

    def specify_with_graph(self, graph):
        class SpecifiedCallPath:
            def __init__(self, cp, graph):
                self._cp = cp
                self._graph = graph

            def __len__(self):
                return len(self._cp)

            def __getitem__(self, index):
                if (index >= len(self) or -index >= len(self)):
                    raise IndexError("Argument index out of range")
                if (index < 0):
                    index = len(self) + index
                return self._cp.get_call_site(self._graph, index)

        return SpecifiedCallPath(self, graph)

    def s(self, graph):
        return self.specify_with_graph(graph)


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

    def get_value(self, CallPath key=CallPath()):
        return get_obj_from_value(deref(self._c_argument).get_value(key._c_callpath))

    def __repr__(self):
        return to_string[CArgument](deref(self._c_argument)).decode('UTF-8')

    def __len__(self):
        return deref(self._c_argument).size()

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
