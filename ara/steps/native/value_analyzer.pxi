# ATTENTION: see step.pyx for c imports. Cython is really bad with double
# imports

import dataclasses
import sys
from ara.util import get_logger
from ara.graph import SigType, ABBType, NodeLevel
from typing import List

class ValuesUnknown(RuntimeError):
  pass

cdef public object py_valueerror = ValuesUnknown

class ConnectionStatusUnknown(RuntimeError):
  pass

cdef public object py_connectionerror = ConnectionStatusUnknown


# TODO make this a dataclass once we have Cython 3
class ValueAnalyzerResult:
        # value: typing.Any
        # offset: List[int]
        # attrs: pyllco.AttributeSet
        # callpath: CallPath

        def __init__(self, value, offset, attrs, callpath):
            self.value = value
            self.offset = offset
            self.attrs = attrs
            self.callpath = callpath

        def __repr__(self):
            return f"ValueAnalyzerResult(value={self.value}, offset={self.offset}, attrs={self.attrs}, callpath={self.callpath})"


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

    def __cinit__(self, graph, tracer=None):
        self._graph = graph
        self._log = get_logger("ValueAnalyzer")
        self._sys_objects = self._graph._va_system_objects

        cdef graph_data.PyGraphData g_data = graph._graph_data
        cdef cgraph.Graph gwrap = cgraph.Graph(graph, g_data._c_data)

        self._c_va = CVA.get(move(gwrap), tracer.get_subtrace("ValueAnalyzer") if tracer is not None else None, self._log)

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
                           ty = None):
        """Retrieve a parameter.

        Arguments:
        callsite    -- callsite, which arguments should be retrieved
        callpath    -- callpath, which leads to this callsite
        argument_nr -- number of argument (index begins at 0)
        hint        -- specify what argument should be searched and how
        ty          -- retrieve only this specific type

        Return the found value, the call specific attributes and an offset.
        value is either an LLVM value or an previously assigned object.
        offset is a tuple of offsets into the value (if it is a compount type).
        """
        callsite = self._check_callsite(callsite)
        if callpath is None:
            callpath = CallPath()
        cdef unsigned arg_nr = argument_nr
        value, offset, attr, rcallpath = deref(self._c_va).py_get_argument_value(
            callsite,
            callpath._c_callpath,
            arg_nr,
            int(hint),
            ty
        )

        if isinstance(value, int):
            value = self._sys_objects[value]

        return ValueAnalyzerResult(value=value, offset=offset, attrs=attr,
                                   callpath=rcallpath)

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

    def get_memory_value(self, intermediate_value: Value, callpath: CallPath = None):
        """Retrieve the most specific memory location of an arbitrary llvm::Value

        For example, the actual memory location of get_return_value
        can be retrieved with that.

        Arguments:
        intermediate_value -- value, which should be followed
        callpath           -- context for the search

        Return the found value and an optional offset within that memory location.
        """
        if callpath is None:
            callpath = CallPath()
        value, offset, attr, rcallpath = deref(self._c_va).py_get_memory_value(intermediate_value._val,
                                                                               callpath._c_callpath)

        if isinstance(value, int):
            value = self._sys_objects[value]

        return ValueAnalyzerResult(value=value, offset=offset, attrs=attr,
                                   callpath=rcallpath)


    def get_assignments(self, value: Value,
                        offset: List[GetElementPtrInst] = [],
                        callpath: CallPath = None):
        """Return all assignments to value or a part of value specified by offset.

        Arguments:
        value    -- The value which assignments should be returned.
        offset   -- optional specifier to restrict the value assignments to this
                    offset (useful for assignments to structs).
        callpath -- callpath to optionally specify the context
        """
        if callpath is None:
            callpath = CallPath()
        cdef vector[const CGep*] c_offset
        cdef GetElementPtrInst gep
        for py_gep in offset:
            gep = py_gep
            c_offset.push_back(gep._gep_inst())
        deref(self._c_va).py_get_assignments(value._val,
                                             c_offset,
                                             callpath._c_callpath)

    def assign_system_object(self, value: Value, sys_obj,
                             offset: List[GetElementPtrInst]=None,
                             callpath: CallPath=None):
        """Assign the system object sys_obj to a given (LLVM) value.

        Normally, these values are retrieved via get_argument_value
        or get_memory_value.

        Arguments:
        value       -- the value, to which the obj should be assigned
        sys_obj     -- the object that should be assigned
                       assignment
                       (pointer) argument
        offset      -- list of offset, to which the object is assigned
        """
        if callpath is None:
            callpath = CallPath()
        if offset is None:
            offset = []
        obj_index = self._phash(sys_obj)
        assert obj_index not in self._sys_objects, "Got two objects with the same hash, when it should not be"
        self._sys_objects[obj_index] = sys_obj
        self._log.debug(f"Assign ID {obj_index} to object {sys_obj}.")
        cdef vector[const CGep*] c_offset
        cdef GetElementPtrInst gep
        for py_gep in offset:
            gep = py_gep
            c_offset.push_back(gep._gep_inst())
        deref(self._c_va).py_assign_system_object(value._val, obj_index, c_offset,
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

        The callpath is currently ignored but might have potential to improve
        the search algorithm.

        Arguments:
        callsite    -- callsite, which arguments should be checked
        callpath    -- callpath, which leads to this callsite. TODO: not used
        argument_nr -- number of argument (index begins at 0)
        sys_obj     -- target candidate
        """
        callsite = self._check_callsite(callsite)
        obj_index = self._phash(sys_obj)
        assert obj_index in self._sys_objects, "sys_obj not assigned"
        return deref(self._c_va).py_has_connection(callsite,
                                                   callpath._c_callpath,
                                                   argument_nr,
                                                   obj_index)

    def find_global(self, name):
        """Return the global LLVM value with the given name (or None)."""
        return deref(self._c_va).py_find_global(name.encode("UTF-8"))
