import graph_tool

import copy
import enum

from dataclasses import dataclass, field
from typing import Any

from ara.graph import SyscallCategory, CallPath, CFG, ABBType

# from ara.util import get_logger
# logger = get_logger("OS_BASE")


class CPUList:
    """Container for storing CPUs."""

    def __init__(self, cpus):
        self._cpus = dict([(cpu.id, cpu) for cpu in cpus])

    def ids(self):
        """Return a generator of all CPU IDs."""
        return self._cpus.keys()

    def one(self):
        """Return the one and only CPU."""
        if len(self._cpus) != 1:
            raise RuntimeError("CPU amount is not one")
        return next(iter(self))

    def __copy__(self):
        return CPUList([x.copy() for x in self._cpus.values()])

    def __hash__(self):
        hush = hash(tuple(sorted(self._cpus.values(),
                                 key=lambda x: x.id)))
        return hush

    def __repr__(self):
        return f"CPUList({[x for x in self]})"

    def __len__(self):
        return len(self._cpus)

    def __iter__(self):
        return iter(self._cpus.values())

    def __getitem__(self, idx):
        return self._cpus[idx]

    def __setitem__(self, idx, cpu):
        if cpu.id != idx:
            raise RuntimeError(f"Trying to assign a CPU with id {cpu.id} to "
                               f"index {idx}.")
        self._cpus[idx] = cpu


class TaskStatus(enum.IntEnum):
    running = 1
    blocked = 2
    ready = 3
    suspended = 4


class ExecState(enum.IntEnum):
    """Execution state of a CPU.

    It can be divided in two categories:
    1. state that has an execution time
      compare with: `exec_state & ExecState.with_time`
    2. state that has no execution time
      compare with: `exec_state & ExecState.no_time`
    """
    # state that has an execution time
    idle = 0b001  # do nothing
    computation = 0b010  # calculating something in the app
    waiting = 0b100  # active waiting in the operating system

    with_time = 0b111

    # state that has no execution time
    call = 0b01000
    syscall = 0b10000

    no_time = 0b11000

    @staticmethod
    def from_abbtype(abb_type):
        return {ABBType.computation: ExecState.computation,
                ABBType.call: ExecState.call,
                ABBType.syscall: ExecState.syscall}[abb_type]


class CrossCoreAction(Exception):
    """The OS has detected a cross core action that cannot be handled.

    Attributes:
        cpu_id -- CPU that is affected
    """

    def __init__(self, cpu_ids):
        self.cpu_ids = cpu_ids


@dataclass
class ControlContext:
    """Changing context for a ControlInstance"""
    status: TaskStatus
    abb: graph_tool.Vertex
    call_path: CallPath

    def __copy__(self):
        """Make a deep copy."""
        return ControlContext(status=self.status,
                              abb=self.abb,
                              call_path=copy(self.call_path))


@dataclass
class CPUBounded:
    """An instance which is bounded to a specific CPU.

    If the instance is not bounded set cpu_id to -1.
    """
    cpu_id: int


@dataclass
class ControlInstance(CPUBounded):
    """All operating system instances (system objects) that contain control
    flow should inherit from this class. Typically, these are threads, tasks,
    ISRs.
    """
    cfg: CFG
    artificial: bool
    function: graph_tool.Vertex


@dataclass
class CPU:
    id: int
    irq_on: bool  # in a more general form, this would be the hardware state
    control_instance: graph_tool.Vertex
    abb: graph_tool.Vertex
    call_path: CallPath
    exec_state: ExecState
    analysis_context: Any  # analysis specific context information

    def copy(self):
        new_ac = None if not self.analysis_context else self.analysis_context.copy()
        return CPU(id=self.id,
                   irq_on=self.irq_on,
                   control_instance=self.control_instance,
                   abb=self.abb,
                   call_path=copy.copy(self.call_path),
                   analysis_context=new_ac,
                   exec_state=self.exec_state)

    def __eq__(self, other):
        return hash(self) == hash(other)

    def __hash__(self):
        ci = self.control_instance and int(self.control_instance)
        abb = self.abb and int(self.abb)
        return hash((self.irq_on, ci, abb, self.call_path, self.exec_state))


_state_id = 0
def _get_id():
    global _state_id
    _state_id += 1
    return _state_id


@dataclass
class OSState:
    id: int = field(init=False, default_factory=_get_id)
    cpus: CPUList
    instances: graph_tool.Graph
    cfg: CFG

    # key: some instance, value: mutable context
    context: dict = field(default_factory=dict, init=False)

    def __eq__(self, other):
        return hash(self) == hash(other)

    def __hash__(self):
        return hash((self.cpus, tuple([(hash(k), hash(v))
                                       for k, v in self.context.items()])))

    def copy(self):
        new_state = OSState(cpus=copy.copy(self.cpus),
                            instances=self.instances,
                            cfg=self.cfg)
        # new context for control instances
        for inst, ctx in self.context.items():
            new_state.context[inst] = copy.copy(ctx)
        return new_state

    def cur_control_inst(self, cpu_id):
        """Return the current running object for the given CPU."""
        cur = self.cpus[cpu_id].control_instance
        if cur:
            return self.instances.vp.obj[self.cpus[cpu_id].control_instance]
        return None

    def cur_context(self, cpu_id):
        """Return the context of current running object for the given CPU."""
        cur = self.cur_control_inst(cpu_id)
        if cur:
            return self.context[self.cur_control_inst(cpu_id)]
        return None


class OSCreator(type):
    def __new__(cls, name, bases, dct):
        x = super().__new__(cls, name, bases, dct)
        x.syscalls = {f: getattr(x, f) for f in dir(x)
                      if hasattr(getattr(x, f), 'syscall')}
        for syscall in list(x.syscalls.values()):
            for alias in syscall.aliases:
                x.syscalls[alias] = syscall
                setattr(x, alias, syscall)
        return x


class OSBase(metaclass=OSCreator):
    # specify possible edge types for the InstanceGraph
    EdgeType = None
    config = {}  # compile time config, TODO: this needs to be in the state

    @classmethod
    def get_name(cls):
        """Get the name of the operating System."""
        return cls.__name__

    @classmethod
    def is_syscall(cls, function_name):
        """Return whether a function name is a system call of this OS."""
        if hasattr(cls, function_name):
            return hasattr(getattr(cls, function_name), "syscall")
        return False

    @classmethod
    def is_interaction(cls, ty) -> bool:
        """Return whether an edge type is an interaction in this OS."""
        return True

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
    def get_initial_state(cfg, instances):
        """Get the OS specific initial state.

        Arguments:
        cfg       -- the control flow graph
        instances -- the already detected global instances
        """
        raise NotImplementedError

    @staticmethod
    def get_interrupts(instances):
        """Get all interrupts that lead to an OS action."""
        raise NotImplementedError

    @staticmethod
    def get_cpu_local_contexts(contexts, cpu_id, instances):
        """Get all contexts that affect cpu_id."""
        raise NotImplementedError

    @staticmethod
    def get_global_contexts(contexts, instances):
        """Get all contexts that affect multiple CPUs."""
        raise NotImplementedError

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        """Handle an (asynchronous) IRQ.

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        irq        -- the IRQ number

        Return:
        The follow up state or None if the IRQ is invalid.
        """
        raise NotImplementedError

    @staticmethod
    def handle_exit(graph, state, cpu_id):
        """Handle an irregular exit.

        Some exits cannot be followed within the ICFG (most notably ISR exits).
        Only the OS model can handle this.

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs

        Return:
        A list of follow up states.
        """
        raise NotImplementedError

    @staticmethod
    def interpret(graph, state, cpu_id, categories=SyscallCategory.every):
        """Entry point for a synchronous os action (system call).

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        categories -- interpret only specific system calls (for performance)

        Return:
        The follow up state.
        """
        raise NotImplementedError()

    @staticmethod
    def schedule(state, cpus=None):
        """Schedule the current state.

        Arguments:
        state -- the current system state
        cpus  -- a list of cpu_ids, defaults to all CPUs
        """
        raise NotImplementedError()
