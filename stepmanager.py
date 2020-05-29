"""Manages all steps.

In principal, there are two different concepts:

- The list of available steps
  A list ob step objects that exists.

- The list of steps that should be executed
  A list of executions. Every execution has a linked step (key: name) and a
  UUID (unique for each execution). Executions are modeled with the StepEvent
  namedtuple. Executions can also have different configurations (passed to the
  step implementation with their option system). Internally every configuration
  is handled with a ConfigEvent namedtuple, that is linked to the execution via
  its UUID.
"""
from typing import List

import logging
from collections import namedtuple

import steps
import graph
import uuid
import copy
import time

from steps.util import raise_and_error as rae

import sys

StepEvent = namedtuple('StepEvent', ['name', 'uuid'])
ConfigEvent = namedtuple('ConfigEvent', ['uuid', 'config'])


def get_uuid(step_name):
    try:
        get_uuid.counter += 1
    except AttributeError:
        get_uuid.counter = -1
    suuid = uuid.uuid3(uuid.NAMESPACE_DNS, f'{step_name}.{get_uuid.counter}')
    return suuid


class SolverException(Exception):
    """An exception occured in stepmanager.Solver."""

class StepManagerException(Exception):
    """An exception occured in stepmanager.StepManager."""


class Solver:
    def __init__(self, esteps, steps):
        """Construct a new Solver:

        Arguments:
        esteps -- the steps to execute (together with its config),
                  a list of dicts.
        steps  -- a dict of all existing steps (key: stepname,
                  value: step object)
        """
        self._log = logging.getLogger(self.__class__.__name__)
        self.esteps = esteps
        self.steps = steps

    def _insert_dependencies(self, step_chain, fulfilled_deps=None):
        """Dependencies resolution for step_chain."""
        # The algorithm works roughly in the following way:
        # 1. Reverse the given execution order (given per self.esteps) so that
        #    the last executed step is the first in the list.
        # 2. Append executions of all dependencies to the list.
        # 3. Remove duplicates.
        # 4. Reverse the order again.
        if not fulfilled_deps:
            fulfilled_deps = []

        rev_chain = list(reversed(step_chain))

        # order is relevant here
        orig_esteps = [x.name for x in rev_chain] + fulfilled_deps

        # insert dependencies as additional StepEvents
        created_steps = 0
        for idx, step in enumerate(rev_chain):
            for dep in self.steps[step.name].get_dependencies():
                if dep not in orig_esteps[idx:]:
                    if dep in orig_esteps:
                        rae(self._log, f"{step.name} depends on {dep} "
                                       "but is scheduled after it",
                            exception=SolverException)
                    rev_chain.append(StepEvent(name=dep, uuid=get_uuid(dep)))
                    created_steps += 1

        # delete duplicates
        execute_chain = []
        exec_names = set()
        for index, step in enumerate(reversed(rev_chain)):
            if index < created_steps and step.name in exec_names:
                continue
            execute_chain.append(step)
            exec_names.add(step.name)

        return execute_chain

    def solve(self):
        """Calculate a valid execution chain while respecting step
        dependencies."""
        # convert self.esteps to StepEvents
        steps = [StepEvent(name=x["name"], uuid=x["uuid"])
                 for x in self.esteps]
        # generate a dict: UUID -> step_has_extra_configuration
        esteps_uuids = {}
        for step in self.esteps:
            config_keys = step.keys() - set(['name', 'uuid'])
            esteps_uuids[step["uuid"]] = bool(config_keys)

        execute_chain = self._insert_dependencies(steps)

        # insert config events into the chain
        exec_with_config = []
        for step in execute_chain:
            if esteps_uuids.get(step.uuid, False):
                exec_with_config.append(ConfigEvent(uuid=step.uuid,
                                                    config=None))
            exec_with_config.append(step)

        return exec_with_config

    def chain_step(self, step_chain, current, new_step):
        """Insert an additional step into the given execution chain.

        Arguments:
        step_chain -- execution chain
        current    -- index in the chain
        new_step   -- step to insert
        """
        # convert new_step to StepEvent and optional ConfigEvent
        name = new_step["name"]
        new_sevent = StepEvent(name=name, uuid=get_uuid(name))
        new_cevent = None
        if new_step.keys() - set(['name', 'uuid']):
            new_cevent = ConfigEvent(uuid=new_sevent.uuid, config=new_step)

        # calculate additional dependencies
        executed_steps = [x.name for x in step_chain[:current]
                          if isinstance(x, StepEvent)]
        execute_chain = self._insert_dependencies([new_sevent], executed_steps)

        if new_cevent:
            execute_chain.insert(-1, new_cevent)

        for elem in reversed(execute_chain):
            step_chain.insert(current + 1, elem)


class ConfigManager:
    """Manages all config events.

    These are mainly two groups: the initial configuration and the
    configuration during step execution.
    """

    def __init__(self, program_config, step_config, time_config, steps):
        """Prepare the different config layer.

        Arguments:
        program_config -- program wide config
        step_config    -- step specific configs
        time_config    -- time and step specific configs
        steps          -- list of steps
        """
        self.p_config = program_config
        self.s_config = step_config
        self.t_config = time_config
        self.t_uuids = dict([(x['uuid'], x) for x in self.t_config])
        self.steps = steps

    def _get_config(self, step_name, extra_config):
        """Overlay the specific configs.

        p_config: initial global config
        s_config: step specific config
        extra_config: additional config

        extra_config overlays s_config overlays p_config.
        """
        # see PEP 448
        return {**self.p_config,
                **(self.s_config.get(step_name, {})),
                **extra_config}

    def apply_initial_config(self):
        """Apply the initial config to all steps."""
        for step in self.steps:
            config = self._get_config(step, {})
            self.steps[step].apply_config(config)


    def apply_new_config(self, config_event):
        """Apply a new config for step specified in config_event.uuid.

        If no extra config is given, use the predefined time_config.
        """
        if config_event.config:
            step_config = config_event.config
        else:
            step_config = self.t_uuids[config_event.uuid]
        config = self._get_config(step_config['name'], step_config)
        self.steps[step_config['name']].apply_config(config)


class StepManager:
    """Manages all steps.

    Knows about all steps and can execute them in correct order.
    Usage: Construct one instance of StepManager and then call execute()
    with a list of step that should be executed.
    """

    def __init__(self, g: graph.Graph, provides=steps.provide_steps):
        """Construct a StepManager.

        Arguments:
        g            -- the system graph

        Keyword arguments:
        provides -- An optional provides function to announce the passes to
                    StepManager
        """
        self._graph = g
        self._steps = {}
        self._log = logging.getLogger(self.__class__.__name__)
        for step in provides():
            step.set_step_manager(self)
            self._steps[step.get_name()] = step
        self._execute_chain = None
        self._current_step_index = None
        self._current_step = None
        self._solver = None

    def get_step(self, name):
        """Get the step with specified name or None."""
        return self._steps.get(name, None)

    def get_steps(self):
        """Get all available steps as set."""
        return set(self._steps.values())

    def chain_step(self, step_config):
        """Insert step immediately after the current running step.

        Potential dependencies are queued before the new step. However, if the
        dependencies were already executed, they are skipped.

        step_config is a step dict exactly as the extra_config configuration.
        """
        if self._execute_chain is None:
            raise StepManagerException(
                "chain_step cannot be called when no step is running."
            )
        self._log.debug(f"A new step was requested {step_config}")
        self._solver.chain_step(self._execute_chain, self._current_step_index,
                                step_config)

    def get_execution_id(self):
        """Get UUID of currently executing step."""
        return self._current_step

    def execute(self, program_config, extra_config, esteps: List[str]):
        """Executes all steps in correct order.

        Arguments:
        program_config -- global program configuration
        extra_config   -- extra step configuration
        esteps         -- list of steps to execute. The elements are strings
                          that matches the ones returned by step.get_name().
        """
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
            self._log.info("No steps to execute.")
            return

        if "steps" in extra_config:
            del extra_config["steps"]

        # give this list the config manager and solver
        config_manager = ConfigManager(program_config, extra_config,
                                       steps, self._steps)
        config_manager.apply_initial_config()

        self._solver = Solver(steps, self._steps)

        self._execute_chain = self._solver.solve()

        # actual execution
        self._log.debug("The following steps will be executed:")
        for step in self._execute_chain:
            if isinstance(step, StepEvent):
                self._log.debug(f"{step.name} (UUID: {step.uuid})")

        for index, step in enumerate(self._execute_chain):
            self._current_step_index = index
            if isinstance(step, ConfigEvent):
                config_manager.apply_new_config(step)
            else:
                self._log.info(f"Executing {step.name} (UUID: {step.uuid})")
                self._current_step = step.uuid

                time_before = time.time()
                self._steps[step.name].run(self._graph)
                time_after = time.time()

                self._current_step = None

                self._log.debug(f"{step.name} had a runtime of "
                                f"{time_after-time_before:0.2f}s.")
