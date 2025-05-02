# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

import copy
import enum

from dataclasses import dataclass, field
from typing import Any, List

import graph_tool

from ara.graph import InstanceGraph, SyscallCategory, CallPath, CFG, ABBType

from ara.util import get_logger
logger = get_logger("OS_BASE")


@dataclass
class MultipleAssignedHandler:
    """Mark a handler as assigned multiple times."""
    handler: Any
    instance: Any


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
    terminated = 5
    starting = 6


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


class InterruptMissing(Exception):
    """The OS must modify interrupt handling but it is missing in the state."""
    def __init__(self, irq_vertex):
        self.irq_vertex = irq_vertex


class OSModelError(Exception):
    """The application behaves in a way that does not fit to the model."""


@dataclass()
class ControlContext:
    """Changing context for a ControlInstance"""
    status: TaskStatus
    abb: graph_tool.Vertex
    call_path: CallPath
    # actual priority, stackable, the last entry is the defining one
    dyn_prio: List[int]

    def __hash__(self):
        return hash((self.__class__,
                     int(self.status),
                     int(self.abb or -1),
                     self.call_path,
                     tuple(self.dyn_prio)))

    def __copy__(self):
        """Make a deep copy."""
        return type(self)(status=self.status,
                          abb=self.abb,
                          call_path=copy.copy(self.call_path),
                          dyn_prio=list(self.dyn_prio))

    def __str__(self):
        return f"ControlContext: status={self.status.name} abb={self.abb} call_path={self.call_path} dyn_prio={self.dyn_prio}"

@dataclass
class CPUBounded:
    """An instance which is bounded to a specific CPU.

    If the instance is not bounded set cpu_id to -1.
    """
    cpu_id: int


@dataclass(kw_only=True)
class ControlInstance(CPUBounded):
    """All operating system instances (system objects) that contain control
    flow should inherit from this class. Typically, these are threads, tasks,
    ISRs.
    """
    cfg: CFG
    artificial: bool
    function: graph_tool.Vertex


@dataclass(kw_only=True)
class IRQ(ControlInstance):
    """Full qualified IRQ.

    For the correct IRQ analysis, we treat IRQs as syscall on artificial CPUs.
    For that they become a control flow attached and act as ControlInstance.
    """
    id: int
    name: str
    isr_handler: int  # node in the instance graph that handles this IRQ
    active: bool

    def __hash__(self):
        # the id should be unique already
        # add the name for extra safety
        return hash((self.id, self.name))

    def __str__(self):
        s = f"IRQ: id={self.id} name=\"{self.name}\" cpu_id={self.cpu_id} cfg={self.cfg} "
        s += f"isr_handler={self.isr_handler} active={self.active} func={self.function}"
        return s

@dataclass
class IRQContext(ControlContext):
    """The context that corresponds to an IRQ."""

    def __hash__(self):
        return super().__hash__()
    
    def __str__(self):
        return super().__str__()


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

    def __str__(self):
        s = f"CPU: Id={self.id} irq_on={self.irq_on} control_instance={self.control_instance} "
        try:
            s += f"Cfg-Abb={self.abb} "
        except ValueError:
            s += f"Cfg-Abb=invalid "
        s += f"callpath={self.call_path} exec_state={self.exec_state.name}"
        return s

@dataclass
class IRQCPU(CPU):
    irq: IRQ
    reference_cpu_id: int

    def __hash__(self):
        return hash((self.irq, super().__hash__()))

    def copy(self):
        new_ac = None if not self.analysis_context else self.analysis_context.copy()
        return IRQCPU(id=self.id,
                      irq_on=self.irq_on,
                      control_instance=self.control_instance,
                      abb=self.abb,
                      call_path=copy.copy(self.call_path),
                      analysis_context=new_ac,
                      exec_state=self.exec_state,
                      irq=self.irq,
                      reference_cpu_id=self.reference_cpu_id)
    
    def __str__(self):
        return "IRQ-" + super().__str__() + f" | irq={self.irq} ref_cpu_id {self.reference_cpu_id}"




_state_id = 0
def _get_id():
    global _state_id
    _state_id += 1
    return _state_id


@dataclass(kw_only=True)
class OSState:

    id: int = field(init=False, default_factory=_get_id)
    cpus: CPUList
    instances: graph_tool.Graph = field(repr=False)
    cfg: CFG = field(repr=False)

    # key: some instance, value: mutable context
    context: dict = field(default_factory=dict, init=False)

    current_index: int = None
    system_count: int = None
    cfg_list: list[CFG] = None
    instances_list: list[InstanceGraph] = None

    @staticmethod
    def reset_id():
        global _state_id
        _state_id = 0

    def __str__(self):
        s = f"\nPrinting OSState: Id={self.id} #cpus={len(self.cpus)}"
        if self.system_count:
            s += f", system_count={self.system_count}\n"
            for i in range(self.system_count):
                s += "\t" + str(self.cfg_list[i]) + ", " + str(self.instances_list[i]) + "\n"
        else:
            s += "\n\t" + str(self.cfg) + " " + str(self.instances)
        for cpu in self.cpus:
            s += f"\n\t{str(cpu)}"
            # for syscalls print name of syscall aswell
            if cpu.exec_state == ExecState.syscall:
                s += " syscall=" + self.cfg.get_syscall_name(cpu.abb)
        s += "\n"
        for k, v in self.context.items():
            s += f"\n\t{k} --- {v}"
        s += "\n"
        return s

    def __post_init__(self):
        self._instances = self.instances
        self._cfg = self.cfg


    def hypersse_state(self, system_count: int, cfg_list: list[CFG], 
                       instances_list: list[InstanceGraph]) -> None:
        self.system_count = system_count
        self.cfg_list = cfg_list
        self.instances_list = instances_list

    # helper function used in interpret
    def get_syscall_name(self, cpu_id: int) -> str:
        abb = self.cpus[cpu_id].abb
        syscall = self.cfg.get_syscall_name(abb)
        assert(syscall, f"Tried to get syscall name of a state that is not in a syscall, cpud_id={cpu_id}, state={self}")
        return syscall
    
    # def choose_cfg(self, system_id: int) -> CFG:
    #     assert(system_id <= self.system_count, f"Choose cfg_id {system_id} to high")
    #     return self.cfg_list[system_id]
        
    # def choose_instances(self, system_id: int) -> InstanceGraph:
    #     assert(system_id <= self.system_count, f"Choose instances_id {system_id} to high")
    #     return self.instances_list[system_id]
        
    @property
    def cfg(self):
        return self._cfg
        
    @cfg.setter
    def cfg(self, cfg):
        self._cfg = cfg
            
    @property 
    def instances(self):
        return self._instances
        
    @instances.setter
    def instances(self, instances):
        self._instances = instances

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
    def get_name(cls) -> str:
        """Get the name of the operating System."""
        return cls.__name__

    @classmethod
    def is_syscall(cls, function_name) -> bool:
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
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        """Get the OS specific initial state.

        Arguments:
        cfg       -- the control flow graph
        instances -- the already detected global instances
        """
        raise NotImplementedError

    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
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
    def interpret(graph: graph_tool.Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:
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
    def schedule(state: OSState, cpus=None) -> None:
        """Schedule the current state.

        Arguments:
        state -- the current system state
        cpus  -- a list of cpu_ids, defaults to all CPUs
        """
        raise NotImplementedError()
