"""Manages all steps.

In principal, there are two different concepts:

- The list of available steps
  A list of step classes that exists.

- The list of steps that should be executed
  A list of executions (StepEntry). Every execution has a linked name
  (key: name) and a UUID (unique for each execution). When they should be
  executed a Step instance is assigned to them together with its config.
  See StepManager._execute_steps_with_deps for the actual code.
"""
import json
import time
import uuid

from typing import List
from dataclasses import dataclass
from collections import defaultdict

import traceback

from .util import get_logger, get_logger_manager, LEVEL
from .steps import provide_steps
from .steps.step import Step
from .graph import Graph

from .steps.util import raise_and_error as rae, current_step

@dataclass
class Config:
    """Aggregate type for program configuration"""
    program: dict
    extra: dict


@dataclass
class StepEntry:
    """Store all step relevant data."""
    name: str
    uuid: uuid.UUID
    explicit: bool # was this step triggered by the user or by chain_step?
    step: Step = None
    runtime: float = None
    all_config: dict = None
    local_config: dict = None


def get_uuid(step_name):
    """Assign a unique id a step with given name."""
    try:
        get_uuid.counter += 1
    except AttributeError:
        get_uuid.counter = -1
    suuid = uuid.uuid3(uuid.NAMESPACE_DNS, f'{step_name}.{get_uuid.counter}')
    return suuid


class StepManagerException(Exception):
    """An exception occured in stepmanager.StepManager."""


class StepManager:
    """Manages all steps.

    Knows about all steps and can execute them in correct order.
    Usage: Construct one instance of StepManager and then call execute()
    with a list of step that should be executed.
    """

    def __init__(self, g: Graph, provides=provide_steps):
        """Construct a StepManager.

        Arguments:
        g            -- the system graph

        Keyword arguments:
        provides -- An optional provides function to announce the passes to
                    StepManager
        """
        self._graph = g
        self._steps = {}
        self._log = get_logger(self.__class__.__name__)
        for step in provides():
            self._steps[step.get_name()] = step
        self._execute_chain = None
        self._config = None
        self._step_history = []
        self._chained_steps = defaultdict(set)
        self._last_step_trace = None

    def clear_history(self):
        self._step_history = []

    def get_history(self):
        return self._step_history

    def _make_step_entry(self, step, explicit=False):
        """Make a StepEntry of a step dict."""
        assert "name" in step, "step without name given."
        uuid = step.get('uuid', get_uuid(step['name']))
        se = StepEntry(name=step["name"], uuid=uuid, explicit=explicit)
        se.local_config = {k: v for k, v in step.items() if (k != "name" and
                                                             k != "uuid")}
        return se

    def _apply_logger_config(self, config):
        """Apply extra logger config to ARA."""
        if 'logger' in config:
            log_levels = config['logger']
            # remove step entries
            for step in self._steps.keys():
                if step in log_levels:
                    self._log.warn("Processing config 'logger': "
                                   f"'{step}' is forbidden. It is a step and "
                                   "will be ignored.")
                    log_levels.pop(step)
            log_levels = dict([(key, LEVEL[lvl])
                               for key, lvl in log_levels.items()])
            get_logger_manager().set_logger_levels(log_levels)

    def _emit_runtime_stats(self, data, stats_format, stats_file, dump_prefix):
        """Output runtime statistics."""
        # formatting
        data = [(x.name, str(x.uuid), x.runtime) for x in data]
        if stats_format == 'json':
            stats_string = json.dumps(data)
        elif stats_format == 'human':
            sn = 'Step name'
            sn_len = max([len(x[0]) for x in data + [sn]])
            stats_string = f'{sn:<{sn_len}} UUID' + 33 * ' ' + 'Runtime\n'
            for s_name, s_uuid, rtime in data:
                stats_string += f'{s_name:<{sn_len}} {s_uuid} {rtime:0.2f}s\n'
        else:
            assert False, "This should be unreachable."

        # output
        if stats_file == 'dump':
            file_name = dump_prefix.replace('{step_name}', 'ARA')
            file_name = file_name.replace('{uuid}', '-')
            ending = {'human': '.txt', 'json': '.json'}[stats_format]
            with open(file_name + 'runtime_stats' + ending, 'w') as f:
                f.write(stats_string)
        elif stats_file == 'logger':
            for line in stats_string.split('\n'):
                self._log.info(line)

    def _get_config(self, step):
        """
        Takes a StepEntry and applies the global, extra and step config to
        it.
        """
        step_opts = [x.get_name() for x in self._steps[step.name].options()]
        step_config = self._config.extra.get(step.name, {})
        config = {**self._config.program, **step_config, **step.local_config}
        config = dict(filter(lambda e: e[0] in step_opts, config.items()))
        return config

    @staticmethod
    def _make_history_dict(step_history):
        """Reformat step_history to a dict."""
        return [{"name": x.name,
                 "uuid": str(x.uuid),
                 "config": x.all_config} for x in step_history]

    def _execute_steps_with_deps(self, step_history):
        """
        Execute all steps from self._execute_chain including its dependencies.
        Stores the history within step_history.
        """
        while self._execute_chain:
            current = self._execute_chain[-1]

            self._log.debug("Beginning execution of "
                            f"{current.name} (UUID: {current.uuid}).")

            # initialize step
            if current.step is None:
                if current.name not in self._steps:
                    rae(self._log, f"Step {current.name} does not exist",
                        exception=StepManagerException)
                step_inst = self._steps[current.name](self._graph, self)
                current.step = step_inst
            current_step.set_wrappee(current.step)

            # apply config
            current.all_config = self._get_config(current)
            self._log.debug(f"Apply config: {current.all_config}")
            current.step.apply_config(current.all_config)

            # dependency handling
            d_hist = self._make_history_dict(step_history)
            dependencies = current.step.get_dependencies(d_hist)
            if dependencies:
                self._log.debug(f"Step has dependencies: {dependencies}")
                dependency = dependencies[0]
                self._execute_chain.append(self._make_step_entry(dependency))
                continue

            d_hist = self._make_history_dict(step_history)
            if current.explicit or current.step.is_necessary_anymore(d_hist):
                # execution
                self._log.info(
                    f"Execute {current.name} (UUID: {current.uuid})."
                )

                if self._runtime_stats:
                    time_before = time.time()

                current.step.run()

                if self._runtime_stats:
                    time_after = time.time()

                # runtime stats handling
                if self._runtime_stats:
                    current.runtime = time_after - time_before
                    self._log.debug(f"{current.name} had a runtime of "
                                    f"{current.runtime:0.2f}s.")
                step_history.append(current)

                for c_step in self._chained_steps[current_step.get_name()]:
                    self.chain_step(dict(c_step))
            else:
                # skip step
                self._log.debug(f"Skip {current.name} (UUID: {current.uuid}).")

            self._execute_chain.pop()

    def get_step(self, name):
        """Get the step with specified name or None."""
        return self._steps.get(name, None)

    def get_steps(self):
        """Get all available steps as set."""
        return set(self._steps.values())

    def chain_step(self, step_config, after: str = None):
        """Insert step into the chain.

        Potential dependencies are queued before the new step. However, if the
        dependencies were already executed, they are skipped.

        step_config is a step dict exactly as the extra_config configuration.

        If after is not set, the step will be chained exactly after the current
        step. If after is set to a step name, the new step will be executed
        after every execution of the specified step. It is not guaranteed that
        it will be executed immediately after the specified step.
        """
        if self._execute_chain is None:
            raise StepManagerException(
                "chain_step cannot be called when no step is running."
            )

        if after:
            self._log.debug(f"Step {step_config} was requested after {after}.")
            self._chained_steps[after].add(frozenset(step_config.items()))
            return

        self._log.debug(f"A new step was requested {step_config}")
        self._execute_chain.insert(-1, self._make_step_entry(step_config,
                                                             explicit=True))

    def change_global_config(self, new_config):
        """Apply a new global config.

        This must be called within an execution chain.

        Arguments:
        new_config -- new global config
        """
        assert self._execute_chain is not None
        assert self._config is not None
        self._config.program = {**self._config.program, **new_config}

    def get_execution_id(self):
        """Get UUID of currently executing step."""
        if self._execute_chain:
            return self._execute_chain[-1].uuid
        return None

    def get_execution_chain(self):
        """Returns the Execution Chain"""
        if self._execute_chain:
            return self._execute_chain
        return []

    def execute(self, program_config, extra_config, esteps: List[str]):
        """Executes all steps in correct order.

        Arguments:
        program_config -- global program configuration
        extra_config   -- extra step configuration
        esteps         -- list of steps to execute. The elements are strings
                          that matches the ones returned by step.get_name().
        """

        self.init_execution(program_config, extra_config, esteps)
        self._execute_steps_with_deps(self._step_history)
        self.finish_execution(program_config)

    def init_execution(self, program_config, extra_config, esteps: List[str]):
        """Initialises the execution."""
        self._apply_logger_config(extra_config)

        # get a list of steps, either from extra_config or esteps
        # output is a list of dicts with at least UUID and name key.
        ecsteps = extra_config.get("steps", None)
        steps = []
        if ecsteps:
            assert esteps is None
            for step in ecsteps:
                if isinstance(step, dict):
                    nstep = step
                else:
                    nstep = {"name": step}
                nstep['uuid'] = get_uuid(nstep['name'])
                steps.append(nstep)
        elif esteps:
            for step in esteps:
                steps.append({"name": step,
                              "uuid": get_uuid(step)})

        if not steps:
            self._log.warning("No steps to execute.")
            return

        if "steps" in extra_config:
            del extra_config["steps"]

        config = Config(program=program_config, extra=extra_config)

        # extract the step manager specific config
        self._runtime_stats = program_config['runtime_stats']

        self._execute_chain = [self._make_step_entry(step, explicit=True)
                               for step in reversed(steps)]
        self._config = config

    def finish_execution(self, program_config):
        """Finishes the execution.

        """
        runtime_stats_file = program_config['runtime_stats_file']
        runtime_stats_format = program_config['runtime_stats_format']
        dump_prefix = program_config['dump_prefix']

        self._config = None
        self._execute_chain = None

        if self._runtime_stats:
            self._emit_runtime_stats(self._step_history, runtime_stats_format,
                                     runtime_stats_file, dump_prefix)

    def is_next_step_traceable(self):
        """ Returns true if the next step in the execution chain supports tracing of its algorithm."""
        next_step_entry = self._execute_chain[-1]
        if next_step_entry.step is None or not hasattr(next_step_entry.step, "is_traceable"):
            return False

        return self._execute_chain[-1].step.is_traceable()

    def get_trace(self):
        """ Returns the trace of the last step ran."""
        return self._last_step_trace

    def step(self):

        try:

            current = self._execute_chain[-1]

            current_traceable = self.is_next_step_traceable()

            self._last_step_trace = None

            self._log.debug("Beginning execution of "
                            f"{current.name} (UUID: {current.uuid}).")

            # initialize step
            if current.step is None:
                if current.name not in self._steps:
                    rae(self._log, f"Step {current.name} does not exist",
                        exception=StepManagerException)
                step_inst = self._steps[current.name](self._graph, self)
                current.step = step_inst
            current_step.set_wrappee(current.step)

            # apply config
            current.all_config = self._get_config(current)
            self._log.debug(f"Apply config: {current.all_config}")
            current.step.apply_config(current.all_config)

            # dependency handling
            d_hist = self._make_history_dict(self._step_history)
            dependencies = current.step.get_dependencies(d_hist)
            if dependencies:
                self._log.debug(f"Step has dependencies: {dependencies}")
                dependency = dependencies[0]
                self._execute_chain.append(self._make_step_entry(dependency))
                return 1 # previously continue,

            d_hist = self._make_history_dict(self._step_history)
            if current.explicit or current.step.is_necessary_anymore(d_hist):
                # execution
                self._log.info(
                    f"Execute {current.name} (UUID: {current.uuid})."
                )

                if self._runtime_stats:
                    time_before = time.time()

                current.step.run()

                if self._runtime_stats:
                    time_after = time.time()

                if current_traceable:
                    self._last_step_trace = current.step.trace

                # runtime stats handling
                if self._runtime_stats:
                    current.runtime = time_after - time_before
                    self._log.debug(f"{current.name} had a runtime of "
                                    f"{current.runtime:0.2f}s.")
                self._step_history.append(current)

            else:
                # skip step
                self._log.debug(f"Skip {current.name} (UUID: {current.uuid}).")

            self._execute_chain.pop()

        except Exception as e:
            print(e)
            print(traceback.format_exc())

        return 0