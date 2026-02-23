# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from collections import defaultdict
from copy import copy
from dataclasses import dataclass, field
from enum import IntEnum
from itertools import chain
from typing import Any, List
from graph_tool import Graph, GraphView
from graph_tool.search import dfs_iterator
from ara.graph.mix import CFType

from ara.util import get_logger
from ara.graph import CallPath, InstanceGraph, SyscallCategory, SigType, single_check, edge_types, CFG

from ara.graph.mix import ARA_ENTRY_POINT

from .os_util import (
    Arg,
    syscall,
    set_next_abb
)
from .os_base import (
    OSBase,
    OSState,
    CPUList,
    CPU,
    ControlInstance,
    CrossOSEvent,
    TaskStatus,
    ControlContext,
    CrossCoreAction,
    ExecState,
    CPUBounded,
    IRQ,
    IRQContext,
    InterruptMissing,
)

from ara.util import get_logger
logger = get_logger("BareMetal")

@dataclass(repr=False)
class Callback(CrossOSEvent):

    name: str
    abb: int
    prev_abb: int | None

    def __hash__(self):
        return hash(self.__class__.__name__ + self.name)
    
    def __str__(self):
        s = f"\33[1;36mCallback\033[0m: cpu_id={self.cpu_id} name={self.name} abb={self.abb} prev={self.prev_abb}"
        return s


class BareMetal(OSBase):
    """BareMetal model."""

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        """Get the OS specific initial state.

        Arguments:
        cfg       -- the control flow graph
        instances -- the already detected global instances
        """
        
        # hardcoded as singlecore 0
        cpu_id = 0
     
        # find ara fake entry point and create CPU on it
        entry_abb = int(cfg.get_entry_abb(cfg.get_function_by_name(ARA_ENTRY_POINT)))
        cpus = [CPU(id=cpu_id,
                irq_on=True,
                control_instance=None,
                abb=entry_abb,
                call_path=CallPath(),
                exec_state=ExecState.computation,
                analysis_context=None,
                cfg=cfg)]
        
        # create initial state with a dummy context
        state = OSState(cpus=CPUList(cpus), instances=instances, cfg=cfg)

        # dummy context
        # state.context["BareMetal"] = 1

        return state

    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        """Get all contexts that affect cpu_id."""

        logger.debug(f"LocalContext: id={cpu_id} instances={instances}")
        logger.debug("Printing context:\n")
        local_contexts = []
        for inst, ctx in context.items():
            logger.debug(f"{inst}  ---  {ctx}")
            if getattr(inst, "cpu_id", None) == cpu_id:
                local_contexts.append((inst, ctx))
        return dict(local_contexts)

    @staticmethod
    def get_global_contexts(contexts, instances):
        """Get all contexts that affect multiple CPUs."""
        return {}

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
    def handle_exit(graph: Graph, state: OSState, cpu_id: int) -> List[OSState]:
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
        return []

    @staticmethod
    def interpret(graph: Graph, state: OSState, cpu_id: int, categories=SyscallCategory.every) -> OSState:
        """Entry point for a synchronous os action (system call).

        Arguments:
        graph      -- the system graph
        state      -- the current system state (see the State class)
        cpu_id     -- the CPU where the system call occurs
        categories -- interpret only specific system calls (for performance)

        Return:
        The follow up state.
        """
        cfg = graph.cfg
        abb = state.cpus[cpu_id].abb
        syscall = cfg.get_syscall_name(abb)
        logger.debug(
            f"Get syscall: {syscall}, CPU {cpu_id}, "
            f"ABB: {cfg.vp.name[abb]}"
            f" (in {cfg.vp.name[cfg.get_function(abb)]})"
        )

        if not hasattr(BareMetal, syscall):
            logger.info("Skipping syscall, since from hypervisor")
            state = state.copy()
            set_next_abb(state, cpu_id)
            return state

        syscall_function = getattr(BareMetal, syscall)

        return syscall_function(graph, state, cpu_id)

    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:
        """Schedule the current state.

        Arguments:
        state -- the current system state
        cpus  -- a list of cpu_ids, defaults to all CPUs
        """
        # check for exit abb
        exit_abb = int(state.cfg.get_exit_abb(state.cfg.get_function_by_name(ARA_ENTRY_POINT)))
        cpu: CPU = state.cpus.one()

        # manually set to cpu to idle at last ABB
        if int(cpu.abb) == exit_abb:
            cpu.exec_state = ExecState.idle

        # check if the cross OS event callback was interrupted when going idle
        # cb_list: Callback = state.context_get_instances(str)
        # if cb_list:
        #     # TODO check for multiple callback
        #     cb: Callback = state.context[cb_list[0]]
        #     if cb.prev_abb and state.cfg.vp.is_exit[cpu.abb]:
        #         cpu.abb = cb.prev_abb
        #         cb.prev_abb = None

        return

    # For HyperSSE/Xen
    @staticmethod
    def move_context(context: dict, target_cpu_id: int) -> dict:
        """HyperSSE starts with each system thinking its running on cpu 0, 
         this function moves the context to target_cpu_id
         single core contexte mit cpu0 -> single core contexte mit cpuNEW"""

        logger.info(f"Moved context to CPU {target_cpu_id} for HyperSSE.")
        new_context = {}
        for k,v in context.items():
            if isinstance(k, CPUBounded):
                k.cpu_id = target_cpu_id
                new_context[k] = v
            elif isinstance(k, str):
                new_context[k] = v
            else:
                logger.error(f"move_context: Unkown context of type: {type(k)}")
                new_context[k] = v
    
        return new_context
    
    def move_irqhandler(irq: IRQ, inst: InstanceGraph, target_cpu_id: int) -> None:
        """When FakeIRQ-CPUs get added in add_interrupts(...) at the beginning of MultiSSE, the 
         IRQ is generated from the InstanceGraph, which does not know the cpu_id's 
         in HyperSSE. Since Zephyr and Autosar use a different IRQ-obj an OS-wrapper is needed."""

        raise NotImplementedError()

    @staticmethod
    def find_cross_os_event(state: OSState, cpu_id: int, cb: str) -> CrossOSEvent:
        """BareMetal supports a function as CrossOSEvents"""

        # @staticmethod
        # def trim_llvm(s: str) -> str:
        #     return s[3:-2]
            
        # cb = trim_llvm(cb)
        try:
            entry_abb = state.cfg.get_entry_abb(state.cfg.get_function_by_name(cb))
            c = Callback(cpu_id=cpu_id, name=cb, abb=entry_abb, prev_abb=None)
            state.context[c] = cb
        except AssertionError:
            logger.warning(f"CrossOSEvent: \"{cb}\" has no entry_abb, if it should have one add it to Xen: meson.build.")
            return None

        return c

    @staticmethod
    def trigger_cross_os_event(state: OSState, cpu_id: int, event: CrossOSEvent) -> OSState:
        """Wrapper to apply the event to the given state, currently only ActivateTask is supported."""
        
        # change active ABB on CPU, set to compution from idle

        assert isinstance(event, Callback), f"{event} is no Callback"
        
        for c in state.cpus:
            if c.id == cpu_id:
                cpu: CPU = c
        assert cpu, "No CPU found!"

        event.prev_abb = int(cpu.abb)
        cpu.abb = event.abb
        cpu.exec_state = ExecState.computation
        
        # hack return function into CFG
        # e = state.cfg.add_edge(callback.abb, callback.prev_abb)
        # state.cfg.ep.type[e] = CFType.icf
        # TODO add callpath

        return state
    
    @syscall(
        categories={SyscallCategory.comm},
        signature=(Arg("int_arg", ty=int, raw_value=True, hint=SigType.value),),
    )
    def BareMetal_Dummy(cfg, state, cpu_id, args, va):
        """Example for a custom system call/function"""

        int_arg = args.int_arg.value.get()
        logger.warning(f"Dummy syscall with arg: {int_arg}")

        return state
    

    @syscall(
        categories={SyscallCategory.comm},
        signature=tuple(), custom_control_flow=False)
    def BareMetal_Idle(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        """Annotion syscall that shows the end of a analysis relevant control.
         Without it the analysis might skip relevant code areas without syscalls,
         like main()."""

        exit_abb = int(state.cfg.get_exit_abb(state.cfg.get_function_by_name(ARA_ENTRY_POINT)))
        cpu: CPU = state.cpus.one()

        # manually set to cpu to idle at last ABB
        cpu.abb = exit_abb
        cpu.exec_state = ExecState.idle

        return state