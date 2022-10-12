# cython: language_level=3
"""Common description of both Python and C++ steps. A step is a part of
ARA, that fulfils one specific task. Therefore, it manipulates the systemgraph
in a specific way.
"""

cimport cstep
cimport cgraph
cimport graph_data

include "project_config.pxi"

IF STEP_TESTS:
    cimport test

from cython.operator cimport dereference as deref
from libcpp.memory cimport shared_ptr, unique_ptr
from common.backported_utility cimport move
from libcpp.memory cimport static_pointer_cast as spc
from libcpp.string cimport string
from libc.stdint cimport int64_t
from cy_helper cimport make_step_fac

cimport cy_helper
cimport option as coption

# includes for value_analyzer.pxi
from value_analyzer cimport ValueAnalyzer as CVA
from graph_data cimport CallPath, PyGraphData
from libcpp.vector cimport vector
from ir cimport Value as CValue, GetElementPtrInst as CGep
from pyllco cimport Value, GetElementPtrInst


import json
import logging
import inspect
from typing import List
from collections import defaultdict

from ara.steps import option
from ara.util import LEVEL

cdef class SuperStep:
    """Super class for Python and C++ steps. Do not use this class directly.
    """
    cdef public object _graph
    cdef public object _log
    cdef public object _step_manager
    cdef public object _config

    def __init__(self, graph, step_manager):
        """Initialize a Step."""
        self._graph = graph
        self._log = logging.getLogger(self.get_name())
        self._step_manager = step_manager
        self._config = None

    def get_dependencies(self, step_history):
        """Define all dependencies of the step.

        Returns a list of dependencies. This means, that the step
        depends on _all_ of the defined steps.

        The function is called before every attempted execution of the step and
        must evaluate to the empty list to get the step executed.

        It gets the step history as input, where the decision can be based on:
        "The step history contains a specific step already so I don't need to
        request it anymore."

        Both, the step_history and the return value need to be a list of dicts.
        Every dict contain a step description in the following format:
        {
            "name": step name,
            "uuid": step uuid (only present in the step history)
            "config": { "key": value } a requested or executed step config
        }

        """
        return []

    def is_necessary_anymore(self, step_history) -> bool:
        """Determines, if the step needs execution yet.

        In some cases, the step was already executed as part of other
        dependencies or user will. Steps that are not explicitly requested (per
        user config or chain_step) but only by a dependency are therefore asked
        with this function, if they need another run.

        The default implementation decides this with this policy:
        If the step was already executed with the same configuration it is not
        necessary anymore.

        If needed, this function should be overwritten.
        """
        for step in reversed(step_history):
            if (step['name'] == self.get_name() and
                step['config'] == self._config):
                return False
        return True

    def run(self):
        """Do the actual action of the step."""
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
        self._config = config
        self._apply_config(config)

    @classmethod
    def get_name(cls) -> str:
        """Return a unique name of the step. The name is used as ID for the
        step."""
        pass

    @classmethod
    def get_description(cls):
        """Return a descriptive string, that explains what the step is doing."""
        pass

    @classmethod
    def options(cls) -> List[option.Option]:
        """Get per step configuration options."""
        return []


class Step(SuperStep):
    """Python representation of a step. This is the superclass for all other
    steps."""
    # ATTENTION: if you change this list, also change the option list in
    # step.h in class Step
    # All of these options are also present in ara.py and have their
    # defaults from argparse.
    log_level = option.Option("log_level",
                              "Adjust the log level of this step.",
                              option.Choice(*LEVEL.keys()),
                              is_global=True)
    dump = option.Option("dump",
                         "If possible, dump the changed graph into a "
                         "dot file.",
                         option.Bool(),
                         is_global=True)
    dump_prefix = option.Option("dump_prefix",
                                "If a file is dumped, set this as "
                                "prefix for the files"
                                "(default: dumps/{step_name}.{uuid}.).",
                                option.String(),
                                is_global=True)
    trace_algorithm = option.Option(
        "trace_algorithm",
        "Create a trace of supported algorithms for the gui to visualize",
        option.Bool(),
        is_global=True
    )

    def __init__(self, graph, step_manager):
        super().__init__(graph, step_manager)
        self._opts = []
        is_option = lambda x: isinstance(x, option.Option)
        for name, obj in inspect.getmembers(self, is_option):
            opt = obj.instantiate(self.get_name())
            setattr(self, name, opt)
            self._opts.append(opt)

    def _get_step_data(self, data_class):
        if self.get_name() not in self._graph.step_data:
            self._graph.step_data[self.get_name()] = data_class()
        return self._graph.step_data[self.get_name()]

    def _set_step_data(self, value):
        self._graph.step_data[self.get_name()] = value

    def _apply_config(self, config):
        for option in self._opts:
            option.check(config)

        level = self.log_level.get()
        if level:
            self._log.setLevel(LEVEL[level])
        dump_prefix = self.dump_prefix.get()
        if dump_prefix:
            new_dp = dump_prefix.replace(r'{step_name}', self.get_name())
            new_dp = new_dp.replace(
                r'{uuid}',
                str(self._step_manager.get_execution_id())
            )
            self.dump_prefix.check({'dump_prefix': new_dp})

    def _fail(self, msg, error=RuntimeError):
        """Print msg to as error and raise error."""
        self._log.error(msg)
        raise error(msg)

    def get_dependencies(self, step_history):
        single_deps = self.get_single_dependencies()
        history = defaultdict(list)
        for step in step_history:
            history[step["name"]].append(step)
        remaining_deps = []
        remaining_configured_deps = []
        for dep in single_deps:
            if isinstance(dep, str):
                if dep not in history:
                    remaining_deps.append({"name": dep})
            else:
                if dep["name"] in history:
                    for step in history[dep["name"]]:
                        if all([step["config"].get(k, None) == v
                                for k, v in dep.items() if k != "name"]):
                            break
                    else:
                        remaining_configured_deps.append(dep)
                else:
                    remaining_configured_deps.append(dep)
        return remaining_deps + remaining_configured_deps

    def get_single_dependencies(self):
        """
        Implement this function to request a list of dependencies that need to
        be executed exactly one time.

        The return value has to be a list of strings or dict, where the strings
        describing the step name or a dict is returned in the same format as
        defined in get_dependencies().
        """
        return []

    @classmethod
    def get_name(cls):
        return cls.__name__

    @classmethod
    def get_description(cls) -> str:
        return inspect.cleandoc(cls.__doc__)

    @classmethod
    def options(cls) -> List[option.Option]:
        is_option = lambda x: isinstance(x, option.Option)
        return list(map(lambda x: x[1], inspect.getmembers(cls, is_option)))


cdef class NativeStepFactory:
    cdef unique_ptr[cstep.StepFactory] _c_step_fac
    cdef object _recipe_step

    def __init__(self, recipe_step=NativeStep):
        self._recipe_step = recipe_step

    def __call__(self, graph, step_manager):
        cdef unique_ptr[cstep.Step] _c_step

        cdef graph_data.PyGraphData g_data = graph._graph_data
        cdef cgraph.Graph gwrap = cgraph.Graph(graph, g_data._c_data)

        cdef NativeStep n_step = self._recipe_step(graph, step_manager,
                                                   self.get_name(),
                                                   self.get_description())

        _c_step = deref(self._c_step_fac).instantiate(n_step._log, move(gwrap),
                                                      step_manager)
        n_step._c_step = move(_c_step)
        return n_step

    def get_name(self):
        return deref(self._c_step_fac).get_name().decode('UTF-8')

    def get_description(self) -> str:
        return deref(self._c_step_fac).get_description().decode('UTF-8')

    cdef getTy(self, unsigned ctype, const coption.Option* opt):
        if ctype == <unsigned> coption.INT:
            return option.Integer()
        if ctype == <unsigned> coption.FLOAT:
            return option.Float()
        if ctype == <unsigned> coption.BOOL:
            return option.Bool()
        if ctype == <unsigned> coption.STRING:
            return option.String()
        if ctype == <unsigned> coption.CHOICE:
            args = cy_helper.get_type_args(opt).decode('UTF-8')
            return option.Choice(*args.split(':'))
        if (ctype & (<unsigned> coption.LIST)) == <unsigned> coption.LIST:
            ty = self.getTy(ctype & ~(<unsigned> coption.LIST), opt)
            return option.List(ty)
        if ctype == <unsigned> coption.RANGE:
            args = cy_helper.get_type_args(opt).decode('UTF-8')
            low, high = args.split(':')
            return option.Range(low, high)
        return None

    def options(self):
        opts = cy_helper.repack(deref(self._c_step_fac))
        pyopts = []

        for entry in opts:
            pyopts.append(option.Option(name=entry.get_name().decode('UTF-8'),
                                        help=entry.get_help().decode('UTF-8'),
                                        ty = self.getTy(entry.get_type(), entry),
                                        is_global=entry.is_global()))
        return pyopts


cdef class NativeStep(SuperStep):
    """Constructs a dummy Python class for a C++ step.

    Use native_fac() to construct a NativeStep.
    """
    cdef unique_ptr[cstep.Step] _c_step
    cdef public object _name
    cdef public object _description

    def __init__(self, graph, step_manager, name, description):
        # name must be assigned _before_ calling of the super constructor
        self._name = name
        self._description = description
        super().__init__(graph, step_manager)

    def get_dependencies(self, step_history):
        step_history_json = json.dumps(step_history)
        deps_s = cy_helper.get_dependencies(
            deref(self._c_step),
            step_history_json.encode('UTF-8')
        ).decode('UTF-8')
        deps = json.loads(deps_s)
        return deps

    def run(self):
        deref(self._c_step).run()

    def get_name(self) -> str:
        return self._name

    def get_description(self):
        return self._description

    def get_side_data(self):
        super().get_side_data()

    def _apply_config(self, config: dict):
        # this is a lot easier on the Python side, so do it here
        if 'dump_prefix' in config:
            dp = config['dump_prefix']
            dp = dp.replace('{step_name}', self.get_name())
            dp = dp.replace('{uuid}',
                            str(self._step_manager.get_execution_id()))
            config['dump_prefix'] = dp

        deref(self._c_step).apply_config(config)

include "value_analyzer.pxi"

cdef _native_step_fac(unique_ptr[cstep.StepFactory] step_fac):
    """Construct a NativeStep. Expects an already constructed C++-Step pointer.
    This pointer can be retrieved with step_fac[...]().

    Don't use this function. Use provide_steps to get all steps.
    """
    n_step = NativeStepFactory()
    n_step._c_step_fac = move(step_fac)
    return n_step


def provide_steps():
    """Provide a list of all native steps. This also constructs as many
    objects as steps exist.
    """
    return [_native_step_fac(make_step_fac[cstep.BBSplit]()),
            _native_step_fac(make_step_fac[cstep.BBTimings]()),
            _native_step_fac(make_step_fac[cstep.CDummy]()),
            _native_step_fac(make_step_fac[cstep.CompInsert]()),
            _native_step_fac(make_step_fac[cstep.FakeEntryPoint]()),
            _native_step_fac(make_step_fac[cstep.FnSingleExit]()),
            _native_step_fac(make_step_fac[cstep.CallGraph]()),
            _native_step_fac(make_step_fac[cstep.IRWriter]()),
            _native_step_fac(make_step_fac[cstep.IRReader]()),
            _native_step_fac(make_step_fac[cstep.LLVMMap]()),
            _native_step_fac(make_step_fac[cstep.LLVMOptimization]()),
            _native_step_fac(make_step_fac[cstep.LoadFreeRTOSConfig]()),
            _native_step_fac(make_step_fac[cstep.ReplaceSyscallsCreate]()),
            _native_step_fac(make_step_fac[cstep.ResolveFunctionPointer]()),
            _native_step_fac(make_step_fac[cstep.SVFAnalyses]()),
            _native_step_fac(make_step_fac[cstep.SVFTransformation]())]

def provide_test_steps():
    IF STEP_TESTS:
        """Do not use this, only for testing purposes."""
        return [_native_step_fac(make_step_fac[test.BBSplitTest]()),
                _native_step_fac(make_step_fac[test.CFGOptimizeTest]()),
                _native_step_fac(make_step_fac[test.CompInsertTest]()),
                _native_step_fac(make_step_fac[test.FnSingleExitTest]()),
                _native_step_fac(make_step_fac[test.LLVMMapTest]()),
                _native_step_fac(make_step_fac[test.Test0Step]()),
                _native_step_fac(make_step_fac[test.Test2Step]())]
    ELSE:
        return []

# make this name extra long, since we have no namespaces here
cdef public void step_manager_chain_step(object step_manager, const char* config):
    py_config = json.loads(config)
    step_manager.chain_step(py_config)

cdef public void step_manager_change_global_config(object step_manager, const char* config):
    py_config = json.loads(config)
    step_manager.change_global_config(py_config)

cdef public const char* step_manager_get_execution_id(object step_manager):
    return str(step_manager.get_execution_id()).encode('UTF-8')

include "tracer_api.pxi"
