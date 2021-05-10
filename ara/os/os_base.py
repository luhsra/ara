import graph_tool

from dataclasses import dataclass
from typing import List, Any

from ara.graph import SyscallCategory, CallPath


class ControlInstance:
    """All operating system instances (system objects) that contain control
    flow should inherit from this class. Typically, these are threads, tasks,
    ISRs.
    """
    pass


@dataclass
class CPU:
    irq_on: bool # in a more general form, this would be the hardware state
    control_instance: graph_tool.Vertex
    abb: graph_tool.Vertex
    call_path: CallPath
    analysis_context: Any # analysis specific context information


@dataclass
class OSState:
    cpus: List[CPU]
    instances: graph_tool.Graph


class OSBase:
    config = {}

    @classmethod
    def get_name(cls):
        """Get the name of the operating System."""
        return cls.__name__

    @staticmethod
    def get_special_steps():
        """Return OS specific preprocessing steps."""
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        return ValueAnalyzer.get_dependencies()

    @staticmethod
    def has_dynamic_instances():
        """Does this OS create instances at runtime?"""
        raise NotImplementedError

    @staticmethod
    def get_initial_state():
        """Get the OS specific initial state."""
        raise NotImplementedError

    @staticmethod
    def interpret(graph, state, cpu, categories=SyscallCategory.every):
        """Entry point for a synchronous os action (system call).

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu        -- the CPU where the system call occurs
        categories -- interpret only specific system calls (for performance)

        Return:
        A list of follow up states.

        TODO: signaling an external action
        """
        raise NotImplementedError()
