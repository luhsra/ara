# cython: language_level=3
"""Common description ob both Python and C++ steps. A step is a part of
Arsa, that fulfils one specific task. There it manipulates the systemgraph in
a specific way.

Steps can have dependencies respectively depend on other steps, the
stepmanager then fulfils this dependencies.
"""

cimport cstep
cimport cgraph
cimport pyllco

from bb_split cimport BBSplit
from cdummy cimport CDummy
from comp_insert cimport CompInsert
from fn_single_exit cimport FnSingleExit
from icfg cimport ICFG
from ir_reader cimport IRReader
from llvm_basic_optimization cimport LLVMBasicOptimization
from llvm_map cimport LLVMMap
from value_analysis_core cimport ValueAnalysisCore

from test cimport (BBSplitTest,
                   CompInsertTest,
                   FnSingleExitTest,
                   LLVMMapTest,
                   Test0Step,
                   Test2Step)

from cython.operator cimport dereference as deref
from libcpp.memory cimport shared_ptr
from libcpp.memory cimport static_pointer_cast as spc
from libc.stdint cimport int64_t
from cy_helper cimport step_fac, repack, get_type_args
cimport option as coption

import logging
import inspect
from typing import List

from steps import option

import graph


LEVEL = {"critical": logging.CRITICAL,
         "error": logging.ERROR,
         "warn": logging.WARNING,
         "info": logging.INFO,
         "debug": logging.DEBUG}


cdef class SuperStep:
    """Super class for Python and C++ steps. Do not use this class directly.
    """
    cdef public object _log

    def __init__(self):
        """Initialize a Step."""
        self._log = logging.getLogger(self.get_name())

    def get_dependencies(self):
        """Define all dependencies of the step.

        Returns a list of dependencies (str). This means, that the step
        depends on _all_ of the defined steps. The elements of the list are
        strings, that match with the names returned by get_name().
        """
        return []

    def get_name(self) -> str:
        """Return a unique name of the step. The name is used as ID for the
        step."""
        pass

    def get_description(self):
        """Return a descriptive string, that explains what the pass is doing."""
        pass

    def run(self, g):
        """Do the actual action of the pass.

        Arguments:
        g -- the system graph.
        """
        raise NotImplementedError()

    def get_side_data(self):
        """Provide arbitrary side data, that are not belonging to the system
        graph. This can be used to make analysis based on the system graph and
        extract some data not related to the graph itself.

        Return some step specific kind of side data.
        """
        raise NotImplementedError()

    def apply_config(self, config: dict):
        """Apply a new config to the step. This can be done multiple times, so
        different runs with different options are possible."""
        raise NotImplementedError()

    def options(self) -> List[option.Option]:
        """Get per step configuration options."""
        return []


class Step(SuperStep):
    """Python representation of a step. This is the superclass for all other
    steps."""
    def __init__(self):
        super().__init__()
        self.log_level = option.Option("log_level",
                                       "Adjust the log level of this step.",
                                       self.get_name(),
                                       option.Choice(*LEVEL.keys()),
                                       glob=True)
        self.os = option.Option("os",
                                "Select the operating system.",
                                self.get_name(),
                                option.Choice("FreeRTOS", "OSEK"),
                                glob=True)
        self.opts = [self.log_level, self.os]
        self._fill_options()

    def apply_config(self, config):
        for option in self.opts:
            option.check(config)
        level = self.log_level.get()
        if level:
            self._log.setLevel(LEVEL[level])

    def _fail(self, msg, error=RuntimeError):
        """Print msg to as error and raise error."""
        self._log.error(msg)
        raise error(msg)

    def get_name(self):
        return self.__class__.__name__

    def get_description(self) -> str:
        return inspect.cleandoc(self.__doc__)

    def _fill_options(self):
        pass

    def options(self):
        return self.opts


# cdef get_warning_abb(shared_ptr[cgraph.ABB] location):
#     cdef pyobj = graph.create_abb(location)
#     return pyobj


cdef class NativeStep(SuperStep):
    """Constructs a dummy Python class for a C++ step.

    Use native_fac() to construct a NativeStep.
    """

    # the pointer attribute that holds the C++ object
    cdef cstep.Step* _c_pass

    def __init__(self, *args):
        """Fake constructor. Prevent usage of super constructor. Must not
        called directly

        Use native_fac() to construct a NativeStep.
        """
        pass

    def init(self):
        """The actual constructor function. Must not called directly.

        Use native_fac() to construct a NativeStep.
        """
        super().__init__()
        self._c_pass.set_logger(self._log)

    def __dealloc__(self):
        """Destroy the C++ object (if any)."""
        if self._c_pass is not NULL:
            del self._c_pass

    def get_dependencies(self):
        # doing this in one line leads to a compiler error
        deps = self._c_pass.get_dependencies()
        return [x.decode('UTF-8') for x in deps]

    def run(self, g):
        cdef pyllco.Module llvm_w = g._llvm
        cdef cgraph.Graph gwrap = cgraph.Graph(g, llvm_w._mod)
        self._c_pass.run(gwrap)

    def get_name(self) -> str:
        return self._c_pass.get_name().decode('UTF-8')

    def get_description(self):
        return self._c_pass.get_description().decode('UTF-8')

    def get_side_data(self):
        super().get_side_data()

    def apply_config(self, config: dict):
        self._c_pass.apply_config(config)

    cdef getTy(self, unsigned ctype, coption.Option* opt):
        if ctype == <unsigned> coption.INT:
            return option.Integer()
        if ctype == <unsigned> coption.FLOAT:
            return option.Float()
        if ctype == <unsigned> coption.BOOL:
            return option.Bool()
        if ctype == <unsigned> coption.STRING:
            return option.String()
        if ctype == <unsigned> coption.CHOICE:
            args = get_type_args(opt).decode('UTF-8')
            return option.Choice(*args.split(':'))
        if (ctype & (<unsigned> coption.LIST)) == <unsigned> coption.LIST:
            ty = self.getTy(ctype & ~(<unsigned> coption.LIST), opt)
            return option.List(ty)
        if ctype == <unsigned> coption.RANGE:
            args = get_type_args(opt).decode('UTF-8')
            low, high = args.split(':')
            return option.Range(low, high)
        return None

    def options(self):
        opts = repack(deref(self._c_pass))
        pyopts = []

        for entry in opts:
            pyopts.append(option.Option(name=entry.get_name().decode('UTF-8'),
                                        help=entry.get_help().decode('UTF-8'),
                                        step_name=self.get_name(),
                                        ty = self.getTy(entry.get_type(), entry),
                                        glob=entry.is_global()))
        return pyopts


cdef _native_fac(cstep.Step* step):
    """Construct a NativeStep. Expects an already constructed C++-Step pointer.
    This pointer can be retrieved with step_fac[...]().

    Don't use this function. Use provide_steps to get all steps.
    """
    n_step = NativeStep()
    n_step._c_pass = step
    n_step.init()
    return n_step


def provide_steps():
    """Provide a list of all native steps. This also constructs as many
    objects as steps exist.
    """
    return [_native_fac(step_fac[BBSplit]()),
            _native_fac(step_fac[CDummy]()),
            _native_fac(step_fac[CompInsert]()),
            _native_fac(step_fac[FnSingleExit]()),
            _native_fac(step_fac[ICFG]()),
            _native_fac(step_fac[IRReader]()),
            _native_fac(step_fac[LLVMBasicOptimization]()),
            _native_fac(step_fac[LLVMMap]()),
            _native_fac(step_fac[ValueAnalysisCore]())]


def provide_test_steps():
    """Do not use this, only for testing purposes."""
    return [_native_fac(step_fac[BBSplitTest]()),
            _native_fac(step_fac[CompInsertTest]()),
            _native_fac(step_fac[FnSingleExitTest]()),
            _native_fac(step_fac[LLVMMapTest]()),
            _native_fac(step_fac[Test0Step]()),
            _native_fac(step_fac[Test2Step]())]
