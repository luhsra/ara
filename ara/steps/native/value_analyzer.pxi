# ATTENTION: see step.pyx for c imports. Cython is really bad with double
# imports

import pyllco
import sys
from ara.util import get_logger
from ara.graph import SigType, ABBType, NodeLevel

class ValuesUnknown(RuntimeError):
  pass

cdef public object py_valueerror = ValuesUnknown

cdef class ValueAnalyzer:
    """Python wrapper class for the C++ Value Analyzer.

    This class provides all entry functions for the ValueAnalyzer.
    It acts as wrapper for the actual C++ Analysis and as storage container for
    Python objects (mainly self._sys_objects).

    See the C++ class for an actual documentation of the internal working.
    """

    cdef unique_ptr[CVA] _c_va
    cdef object _graph
    cdef object _log
    cdef object _sys_objects

    @staticmethod
    def get_dependencies():
        return ["CallGraph"]

    def __cinit__(self, graph):
        self._graph = graph
        self._log = get_logger("ValueAnalyzer")
        self._sys_objects = self._graph._va_system_objects

        cdef graph_data.PyGraphData g_data = graph._graph_data
        cdef cgraph.Graph gwrap = cgraph.Graph(graph, g_data._c_data)

        self._c_va = CVA.get(move(gwrap), self._log)

    def _check_callsite(self, callsite):
        assert(self._graph.cfg.vp.type[callsite] in [ABBType.syscall,
                                                     ABBType.call])
        if self._graph.cfg.vp.level[callsite] == NodeLevel.abb:
            return self._graph.cfg.get_single_bb(callsite)
        return callsite

    def _phash(self, obj):
        """Get positive hash."""
        return hash(obj) % ((sys.maxsize + 1) * 2)


    def get_argument_value(self, callsite, argument_nr,
                           callpath: CallPath = None,
                           hint: SigType = SigType.undefined,
                           ty = None) -> pyllco.Value:
        """Retrieve a parameter.

        Arguments:
        callsite    -- callsite, which arguments should be retrieved
        callpath    -- callpath, which leads to this callsite
        argument_nr -- number of argument (index begins at 0)
        hint        -- specify what argument should be searched and how
        ty          -- retrieve only this specific type

        Return the found value, the call specific attributes and an offset.
        value is either an LLVM value or an previously assigned object.
        offset is an optional offset into the value (if it is a compount type).
        """
        callsite = self._check_callsite(callsite)
        if callpath is None:
            callpath = CallPath()
        cdef unsigned arg_nr = argument_nr
        value, attr, idx, offset = deref(self._c_va).py_get_argument_value(
            callsite,
            callpath._c_callpath,
            arg_nr,
            int(hint),
            ty
        )

        if idx is not None:
            value = self._sys_objects[idx]

        return value, attr, offset

    def assign_system_object(self, callsite, sys_obj,
                             callpath: CallPath = None, argument_nr=-1):
        """Assign the system object sys_obj to a given (LLVM) callsite.

        Arguments:
        callsite    -- callsite, to which the obj should be assigned
        sys_obj     -- the object that should be assigned
        callpath    -- callpath that is leading to this specific object
                       assignment
        argument_nr -- if specified, assign the sys_obj to the specific
                       (pointer) argument
        """
        callsite = self._check_callsite(callsite)
        if callpath is None:
            callpath = CallPath()
        obj_index = self._phash(sys_obj)
        assert obj_index not in self._sys_objects, "Got two objects with the same hash, when it should not be"
        self._sys_objects[obj_index] = sys_obj
        self._log.debug(f"Assign ID {obj_index} to object {sys_obj}.")
        deref(self._c_va).py_assign_system_object(callsite, obj_index,
                                                  callpath._c_callpath,
                                                  argument_nr)

    def get_return_value(self, callsite, callpath: CallPath = None):
        """Retrieve the next store of return value of the callsite.

        Arguments:
        callsite -- callsite, which return value should be retrieved
        """
        callsite = self._check_callsite(callsite)
        if callpath is None:
            callpath = CallPath()
        return deref(self._c_va).py_get_return_value(callsite,
                                                     callpath._c_callpath)

    def has_connection(self, callsite, callpath: CallPath, argument_nr, sys_obj):
        """Check, if an syscall argument and a target candidate are connected.

        Syscalls often get OS instances as input argument. Sometimes, they
        cannot be found. However it can be checked if there is a (value flow)
        connection at all.

        The syscall argument is specified with the triple
        (callsite, callpath, argument_nr), the target candidate with sys_obj.

        The sys_obj must already be assigned to the ValueAnalyzer
        via assign_system_object.

        Arguments:
        callsite    -- callsite, which arguments should be checked
        callpath    -- callpath, which leads to this callsite
        argument_nr -- number of argument (index begins at 0)
        sys_obj     -- target candidate
        """
        callsite = self._check_callsite(callsite)
        obj_index = self._phash(sys_obj)
        assert obj_index not in self._sys_objects, "sys_obj not assigned"
        return deref(self._c_va).py_has_connection(callsite,
                                                   callpath._c_callpath,
                                                   argument_nr,
                                                   obj_index)
