"""Manages all steps."""
from typing import List

import logging
from collections import namedtuple

import steps
import graph
import uuid
import copy

import sys

StepEvent = namedtuple('StepEvent', ['name', 'uuid'])


class Solver:
    def __init__(self, esteps, steps):
        self.esteps = esteps
        self.steps = steps

    def solve(self):
        print("solve")
        sys.exit(1)
        pass


ConfigEvent = namedtuple('ConfigEvent', ['uuid'])


class ConfigManager:
    def __init__(self, program_config, extra_config, time_config, steps):
        self.p_config = program_config
        self.e_config = extra_config
        self.t_config = time_config
        self.steps = steps

    def apply_initial_config(self):
        for step in self.steps:
            # see PEP 448
            config = {**self.p_config, **(self.e_config.get(step, {}))}
            self.steps[step].apply_config(config)

    def apply_new_config(self, config_event):
        print("newconf")
        sys.exit(1)
        pass


class StepManager:
    """Manages all steps.

    Knows about all steps and can execute them in correct order.
    Usage: Construct one instance of StepManager and then call execute()
    with a list of step that should be executed.
    """

    def __init__(self, g: graph.PyGraph, provides=steps.provide_steps):
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
            self._steps[step.get_name()] = step

    def get_step(self, name):
        """Get the step with specified name or None."""
        return self._steps.get(name, None)

    def get_steps(self):
        """Get all available steps as set."""
        return set(self._steps.values())

    def execute(self, program_config, extra_config, esteps: List[str]):
        """Executes all steps in correct order.

        Arguments:
        program_config -- global program configuration
        extra_config   -- extra step configuration
        esteps         -- list of steps to execute. The elements are strings
                          that matches the ones returned by step.get_name().
        """
        ecsteps = extra_config.get("steps", None)
        steps = []
        if ecsteps:
            assert esteps is None
            for step in ecsteps:
                if isinstance(step, dict):
                    nstep = step
                else:
                    nstep = {"name": step}
                nstep['uuid'] = uuid.uuid4()
                steps.append(nstep)
        elif esteps:
            for step in esteps:
                steps.append({"name": step,
                              "uuid": uuid.uuid4()})

        if not steps:
            self._log.info("No steps to execute.")
            return

        if "steps" in extra_config:
            del extra_config["steps"]

        config_manager = ConfigManager(program_config, extra_config,
                                       steps, self._steps)
        config_manager.apply_initial_config()

        solver = Solver(steps, self._steps)

        execute = solver.solve()

        config_manager.set_execution_chain(execute)

        self._log.debug("The following steps will be executed:")
        for step in execute:
            if isinstance(step, StepEvent):
                self._log.debug(f"{step.name} (UUID: {step.uuid})")

        # for step in esteps:
        #     for dep in self._steps[step].get_dependencies():
        #         esteps.append(dep)

        # execute = []

        # self._log.debug("The following steps will be executed:")
        # for step in reversed(esteps):
        #     if step not in execute:
        #         self._log.debug(step)
        #         execute.append(step)

        for step in execute:
            if isinstance(step, ConfigEvent):
                config_manager.apply_new_config(step)
            else:
                self._log.info(f"Executing {step.name} (UUID: {step.uuid}")
                self._steps[step.name].run(self._graph)
