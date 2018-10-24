import steps
import graph

from typing import List


class StepManager:
    """Manages all steps.

    Knows about all steps and can execute them in correct order.
    Usage: Construct one instance of StepManager and then call execute()
    with a list of step that should be executed.
    """

    def __init__(self, g: graph.PyGraph, config: dict,
                 provides=steps.provide_steps):
        """Construct a StepManager.

        Arguments:
        g      -- the system graph
        config -- the program configuration. This should be a dict.

        Keyword arguments:
        provides -- An optional provides function to announce the passes to
                    StepManager
        """
        self._graph = g
        self._config = config
        self._steps = {}
        for step in provides(config):
            self._steps[step.get_name()] = step

    def execute(self, steps: List[str]):
        """Executes all steps in correct order.

        Arguments:
        steps -- list of passsages to execute. The elements are strings that
                    matches the ones returned by step.get_name().
        """
        # TODO transform this into a graph data structure
        # this is really quick and dirty
        for step in steps:
            for dep in self._steps[step].get_dependencies():
                steps.append(dep)

        executed = set()
        for step in reversed(steps):
            if step not in executed:
                self._steps[step].run(self._graph)
                executed.add(step)
