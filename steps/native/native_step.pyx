# cython: language_level=3
"""Common description ob both Python and C++ steps. A step is a part of
Arsa, that fulfils one specific task. There it manipulates the systemgraph in
a specific way.

Steps can have dependencies respectively depend on other steps, the
stepmanager then fulfils this dependencies.
"""

cimport cstep
cimport cgraph
cimport llvm_data

from agressive_dce cimport AgressiveDCE
from bb_split cimport BBSplit
from cdummy cimport CDummy
from cfg_prep cimport CFGPreparation
from comp_insert cimport CompInsert
from const_prop cimport ConstProp
from dead_code_elimination cimport DeadCodeElimination
from fn_single_exit cimport FnSingleExit
from icfg cimport ICFG
from ir_reader cimport IRReader
from llvm_basic_optimization cimport LLVMBasicOptimization
from llvm_map cimport LLVMMap
from mem2reg cimport Mem2Reg
from reassociate cimport Reassociate
from sparse_cond_const_prop cimport SparseCondConstProp
from simplify_cfg cimport SimplifyCFG
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
from libcpp.string cimport string
from libc.stdint cimport int64_t
from cy_helper cimport step_fac, repack, get_type_args
cimport option as coption

import json
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
    cdef public object _step_manager

    def __init__(self):
        """Initialize a Step."""
        self._log = logging.getLogger(self.get_name())
        self._step_manager = None

    def set_step_manager(self, step_manager):
        """Set the step manager."""
        self._step_manager = step_manager

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
        # ATTENTION: if you change this list, also change the option list in
        # step.h in class Step
        # All of these options are also present in ara.py and have their
        # defaults from argparse.
        self.log_level = option.Option("log_level",
                                       "Adjust the log level of this step.",
                                       self.get_name(),
                                       option.Choice(*LEVEL.keys()),
                                       glob=True)
        self.dump = option.Option("dump",
                                  "If possible, dump the changed graph into a "
                                  "dot file.",
                                  self.get_name(),
                                  option.Bool(),
                                  glob=True)
        self.dump_prefix = option.Option("dump_prefix",
                                         "If a file is dumped, set this as "
                                         "prefix for the files"
                                         "(default: dumps/{step_name}).",
                                         self.get_name(),
                                         option.String(),
                                         glob=True)
        self.opts = [self.log_level, self.dump, self.dump_prefix]
        self._fill_options()

    def _get_step_data(self, g, data_class):
        if self.get_name() not in g.step_data:
            g.step_data[self.get_name()] = data_class()
        return g.step_data[self.get_name()]

    def apply_config(self, config):
        for option in self.opts:
            option.check(config)
        level = self.log_level.get()
        if level:
            self._log.setLevel(LEVEL[level])
        dump_prefix = self.dump_prefix.get()
        if dump_prefix:
            new_dp = dump_prefix.replace('{step_name}', self.get_name())
            self.dump_prefix.check({'dump_prefix': new_dp})

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


cdef class NativeStep(SuperStep):
    """Constructs a dummy Python class for a C++ step.

    Use native_fac() to construct a NativeStep.
    """

    # the pointer attribute that holds the C++ object
    cdef cstep.Step* _c_pass

    def __init__(self, *args):
        """Fake constructor. Prevent usage of super constructor. Must not
        called directly

        Use _native_fac() to construct a NativeStep.
        """
        pass

    def init(self):
        """The actual constructor function. Must not called directly.

        Use _native_fac() to construct a NativeStep.
        """
        super().__init__()
        self._c_pass.python_init(self._log, self._step_manager)

    def set_step_manager(self, step_manager):
        """Set the step manager."""
        self._step_manager = step_manager
        self._c_pass.python_init(self._log, step_manager)

    def __dealloc__(self):
        """Destroy the C++ object (if any)."""
        if self._c_pass is not NULL:
            del self._c_pass

    def get_dependencies(self):
        # doing this in one line leads to a compiler error
        deps = self._c_pass.get_dependencies()
        return [x.decode('UTF-8') for x in deps]

    def run(self, g):
        cdef llvm_data.PyLLVMData llvm_w = g._llvm_data
        cdef cgraph.Graph gwrap = cgraph.Graph(g, llvm_w._c_data)
        self._c_pass.run(gwrap)

    def get_name(self) -> str:
        return self._c_pass.get_name().decode('UTF-8')

    def get_description(self):
        return self._c_pass.get_description().decode('UTF-8')

    def get_side_data(self):
        super().get_side_data()

    def apply_config(self, config: dict):
        # this is a lot easier on the Python side, so do it here
        if 'dump_prefix' in config:
            config['dump_prefix'] = \
                config['dump_prefix'].replace('{step_name}', self.get_name())

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
    return [_native_fac(step_fac[AgressiveDCE]()),
            _native_fac(step_fac[BBSplit]()),
            _native_fac(step_fac[CDummy]()),
            _native_fac(step_fac[CFGPreparation]()),
            _native_fac(step_fac[CompInsert]()),
            _native_fac(step_fac[ConstProp]()),
            _native_fac(step_fac[DeadCodeElimination]()),
            _native_fac(step_fac[FnSingleExit]()),
            _native_fac(step_fac[ICFG]()),
            _native_fac(step_fac[IRReader]()),
            _native_fac(step_fac[LLVMBasicOptimization]()),
            _native_fac(step_fac[LLVMMap]()),
            _native_fac(step_fac[Mem2Reg]()),
            _native_fac(step_fac[Reassociate]()),
            _native_fac(step_fac[SparseCondConstProp]()),
            _native_fac(step_fac[SimplifyCFG]()),
            _native_fac(step_fac[ValueAnalysisCore]())]


def provide_test_steps():
    """Do not use this, only for testing purposes."""
    return [_native_fac(step_fac[BBSplitTest]()),
            _native_fac(step_fac[CompInsertTest]()),
            _native_fac(step_fac[FnSingleExitTest]()),
            _native_fac(step_fac[LLVMMapTest]()),
            _native_fac(step_fac[Test0Step]()),
            _native_fac(step_fac[Test2Step]())]

# make this name extra long, since we have no namespaces here
cdef public void step_manager_chain_step(object step_manager, const char* config):
    py_config = json.loads(config)
    step_manager.chain_step(py_config)

cdef public const char* step_manager_get_execution_id(object step_manager):
    return str(step_manager.get_execution_id()).encode('UTF-8')
