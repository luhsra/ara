# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from dataclasses import dataclass
from graph_tool import Graph
from ara.util import get_logger

from copy import copy

from .os_util import (
    syscall,
    Arg,
    set_next_abb,
    connect_from_here,
    find_instance_node,
    Parenthesis,
)
from ara.graph import CFG, InstanceGraph, SyscallCategory, SigType
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
    IRQCPU,
    IRQContext,
    InterruptMissing,
)
# from .autosar import Task # todo
from ara.steps.multisse_helper.common import CrossExecState

logger = get_logger("XEN")

class XEN(OSBase):
    
    system_count: int = 0
    system_types: list[OSBase] = []
    cfg_list: list[CFG] = []
    instances_list: list[InstanceGraph] = []
    graph_list: list[Graph] = []

    @classmethod
    def is_interaction(cls, ty) -> bool:
        """Return whether an edge type is an interaction in this OS."""
        return True

    @staticmethod
    def has_dynamic_instances():
        """Does this OS create instances at runtime?"""
        raise NotImplementedError

    @staticmethod
    def merge_states(states: list[OSState]) -> OSState:
        cpus: list[CPU] = []
        # instances = InstanceGraph 
        for idx, s in enumerate(states):
            assert len(s.cpus) == 1, f"Tried to merge state that is already multicore {len(s.cpus)}."
            cpu: CPU = s.cpus.one()
            cpu.id = idx
            cpus.append(cpu)

        state = OSState(cpus=CPUList(cpus), cfg=None, instances=None)
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, 
                             instances_list=XEN.instances_list)

        for i, s in enumerate(states):
            new_context = XEN.system_types[i].move_context(s.context, i)
            for k,v in new_context.items():
                state.context[k] = v

        return state

    @staticmethod
    # iterate over all systems and find each local interrupts
    def add_interrupts(state: OSState):
        cpu_idx = max([x.id for x in state.cpus]) + 1
        for idx, instances in enumerate(XEN.instances_list):
            tmp_instances_list = []
            for _, irq in instances.get(IRQ):
                # every irq gets an own CPU
                ctx = state.context[irq]
                if ctx.status == TaskStatus.running:
                    exec_state = CrossExecState.computation
                    cur_abb = ctx.abb
                else:
                    exec_state = CrossExecState.idle
                    cur_abb = None
                irq_cpu = IRQCPU(id=cpu_idx,
                                irq=irq,
                                reference_cpu_id=irq.cpu_id,
                                irq_on=False,
                                control_instance=instances.get_node(irq),
                                abb=cur_abb,
                                call_path=copy(ctx.call_path),
                                exec_state=exec_state,
                                analysis_context=None)
                state.cpus[irq_cpu.id] = irq_cpu
                # reassign irq
                irq.cpu_id = irq_cpu.id
                cpu_idx += 1
                
                XEN.cfg_list.append(XEN.cfg_list[idx])
                XEN.graph_list.append(XEN.graph_list[idx])
                XEN.system_types.append(XEN.system_types[idx])
                XEN.system_count += 1

                # das ist alles ein bissel yikes
                # IRQ Handling needs to find cpu core
                XEN.instances_list[idx].vp.obj[irq.isr_handler].cpu_id = idx


                tmp_instances_list.append(XEN.instances_list[idx])
        XEN.instances_list += tmp_instances_list


    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        logger.info(f"Get inital state from {XEN.system_count} systems.")
        states: OSState = []
        for i in range(XEN.system_count):
            states.append(XEN.system_types[i].get_initial_state(
                cfg=XEN.cfg_list[i],
                instances=XEN.instances_list[i])
                )

        return XEN.merge_states(states)

    @staticmethod
    def find_system_id(state: OSState):
        for idx, cfg in enumerate(XEN.cfg_list):
            if cfg == state.cfg:
                logger.info(f"Scheduling on cpu: {idx}.")

    # used by MultiSSE in _get_single_core_states, to split multicore into singlecore states 
    @staticmethod
    def state_copy_index(old_state: OSState, system_id: int) -> OSState:
         
        new_state = OSState(cpus=copy(old_state.cpus),
                                instances=old_state.instances_list[system_id],
                                cfg=old_state.cfg_list[system_id])
        # new context for control instances
        for inst, ctx in old_state.context.items():
            new_state.context[inst] = copy(ctx)
        return new_state


    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict:
        # since each system is single-core assume id=0
        # here we have to translate back again that each system thinks it has cpu_id 0
        # instances is already set to the right graph

        new_context = XEN.system_types[cpu_id].get_cpu_local_contexts(context, cpu_id, instances)

        return new_context


    @staticmethod
    def get_global_contexts(contexts, cpu_idinstances):
        """Get all contexts that affct multiple CPUs."""
        
        local_contexts = []
        for inst, ctx in contexts.items():

            # weird case of locks for one core
            # if isinstance(inst, Spinlock):
            #     cpus = AUTOSAR.get_cpus_of_spinlock(inst, instances)
            #     if len(cpus) == 1:
            #         continue
            if not hasattr(inst, "cpu_id"):
                local_contexts.append((inst, ctx))
        return dict(local_contexts)

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
        return XEN.system_types[cpu_id].handle_irq(graph, state, cpu_id, irq)

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
        return XEN.system_types[cpu_id].handle_exit(graph, state, cpu_id)

    @staticmethod
    def interpret(graph: Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:

        logger.info(f"Interpret: cpu_id: {cpu_id} System count: {XEN.system_count} {XEN.graph_list}\nCurrent graph: {graph}")
        syscall = state.get_syscall_name(cpu_id)


        if XEN.is_syscall(syscall):
            logger.warning(f"Interpret a xen syscall: {syscall}")
            syscall_function = getattr(XEN, syscall)
            # return state
            return syscall_function(graph, state, cpu_id)
        else:
            return XEN.system_types[cpu_id].interpret(graph=XEN.graph_list[cpu_id], state=state, cpu_id=cpu_id, categories=categories)

    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:

        if cpus is None:
            cpus = [cpu.id for cpu in state.cpus]

        if len(cpus) == 1:
            for idx, cfg in enumerate(XEN.cfg_list):
                if cfg == state.cfg:
                    logger.info(f"Scheduling on cpu: {idx}.")
                    XEN.system_types[idx].schedule(state=state, cpus=cpus)
                    break

        else:
            logger.info(f"Scheduling a xen multicore cpu with: {cpus} cores.")
            states = []

            # convert from dict with cpu_ids into list of states
            for id, state in XEN._get_single_core_states(state).items():
                states.append(state)

            for idx, sc_state in enumerate(states):
                # schedule each state seperatly
                XEN.system_types[idx].schedule(state=sc_state, cpus=cpus)        
                

        
    def _get_single_core_states(multi_core_state) -> dict:
        single_core_states = {}
        for cpu in multi_core_state.cpus:
            # restrict state to this cpu

            # if system count is present it is a XEN state and needs a differnt copy
            if multi_core_state.system_count:
                state = XEN.state_copy_index(multi_core_state, cpu.id)
            else:
                state = multi_core_state.copy()
            state.cpus = CPUList([cpu])
            state.context = XEN.get_cpu_local_contexts(
                multi_core_state.context, cpu.id, state.instances)
            single_core_states[cpu.id] = state

        return single_core_states
    


    # --------------------------- SYSCALLS ---------------------

    # Used for uniques ids
    _sender: int = 0
    _receive: int = 0

    @syscall(categories={SyscallCategory.comm}, 
                     signature=(Arg("remote_dom", ty=int, raw_value=True, hint=SigType.value),
                                Arg("port", ty=int, raw_value=True, hint=SigType.value)),)
    def XEN_test_send_event_channel(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        
        remote_dom = args.remote_dom.value.get_initializer().get()
        port = args.port.value.get_initializer().get()

        XEN._sender += 1
        hyper = HypercallSender(cpu_id=cpu_id, name="HypercallSender"+str(XEN._sender), port=port, target_domain=remote_dom)
        state.context[hyper] = 1

        return state

    @syscall(categories={SyscallCategory.comm},
                     signature=(Arg("source_dom", ty=int, raw_value=True, hint=SigType.value),
                                Arg("port", ty=int, raw_value=True, hint=SigType.value),
                                Arg("event", ty=CrossOSEvent, hint=SigType.symbol)
                                ,),)
    def XEN_test_receive_event_channel(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        
        source_dom = args.source_dom.value.get_initializer().get()
        port = args.port.value.get_initializer().get()
        event_name: str = args.event.value.get_name()

        # Autosar specific renaming
        if event_name.startswith("AUTOSAR_TASK_FUNC_"):
            event_name = event_name.strip("AUTOSAR_TASK_FUNC_")
        
        for k, v in state.context.items():
            if isinstance(k, CrossOSEvent):
                if k.name == event_name:
                     task = k
        assert task, f"Could not find CrossOSEvent {event_name} on domain {cpu_id}"

        XEN._receive += 1
        hyper = HypercallReceiver(cpu_id=cpu_id, name="HypercallReceiver"+str(XEN._receive), port=port, event=task, target_domain=source_dom)
        state.context[hyper] = 1

        return state


    @staticmethod
    def get_remote_id(state: OSState, id: int):
        """
        Check, if another dom/cpu_id is included in state.
        Otherwise raise a CrossCoreAction, which return here again with the other dom/cpu.
        Analog to os.Autosar.check_cpu
        """
        ids = set([x.id for x in state.cpus])

        if id not in ids:
            raise CrossCoreAction(set([id]))
        
    @syscall(categories={SyscallCategory.comm}, 
                     signature=(Arg("remote_dom", ty=int, raw_value=True, hint=SigType.value),
                                Arg("port", ty=int, raw_value=True, hint=SigType.value),),)
    def XEN_test_notify_evtchn(graph: Graph, state: OSState, cpu_id: int, args, va) -> list[OSState]:

        # if we are not hypervised this does nothing
        if graph.os != XEN:
            return state
        
        # need get_initializer for global variables
        port = args.port.value.get_initializer().get()
        remote_dom = args.remote_dom.value.get_initializer().get()

        # check if target in included in state, if not raise CrossCoreAction and return later 
        XEN.get_remote_id(state, remote_dom)

        recver = state.context_get_instances(HypercallReceiver)
        sender = state.context_get_instances(HypercallSender)

        task = None
        for send in sender:
            # filter to sender from this cpu_id
            if send.cpu_id != cpu_id:
                continue
            for revc in recver:
                # filter recevier who receive from this cpu_id
                if revc.target_domain != cpu_id:
                    continue
                # filter that port is correct
                if send.port == revc.port:
                    task = revc.event
        
        state.hypersse_state(system_count=len(state.cpus), cfg_list=XEN.cfg_list, instances_list=XEN.instances_list)

        if task:
        # Activate Task Syntax
            ctx = state.context[task]
            if ctx.status is not TaskStatus.running:
                if ctx.status is TaskStatus.suspended:
                    cfg = task.cfg
                    ctx.abb = cfg.get_entry_abb(task.function)
                ctx.status = TaskStatus.ready
        else:
            logger.warning(f"Did not find CrossOSEvent from domain {cpu_id} to {remote_dom} on port {port}, notify is ignored!")
            logger.warning(f"Should be avoided with timing information.")


        return state

# TODO müssen wir ControlInstance erben?
@dataclass()
class HypercallSender(CPUBounded):
    def __eq__(self, other):
        return self.name == other.name

    def __hash__(self):
        return hash(self.__class__.__name__ + self.name)

    name: str
    port: int
    target_domain: int
    def __str__(self):
        return f"{self.name} on dom:{self.cpu_id} to: {self.target_domain} via port: {self.port}"
    
@dataclass()
class HypercallReceiver(CPUBounded):
    def __eq__(self, other):
        return self.name == other.name

    def __hash__(self):
        return hash(self.__class__.__name__ + self.name)

    name: str
    port: int
    target_domain: int
    event: CrossOSEvent  # event that happens on hypercall

    def __str__(self):
        return f"{self.name} on dom:{self.cpu_id} to: {self.target_domain} via port: {self.port} with: {self.event}"
