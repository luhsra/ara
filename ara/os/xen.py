# SPDX-FileCopyrightText: 2025 Mareike Burg
#
# SPDX-License-Identifier: GPL-3.0-or-later

from dataclasses import dataclass
from typing import Any
from graph_tool import Graph
from ara.util import get_logger

from .autosar import AUTOSAR

from copy import copy

from .os_util import (
    syscall,
    Arg,
)
from ara.graph import CFG, InstanceGraph, SyscallCategory, SigType
from .os_base import (
    OSBase,
    OSState,
    CPUList,
    CPU,
    CrossOSEvent,
    TaskStatus,
    CrossCoreAction,
    CPUBounded,
    IRQ,
    IRQCPU,
)

from ara.steps.multisse_helper.common import CrossExecState, get_single_core_states

logger = get_logger("XEN")

@staticmethod
def read_va_integer(obj: Any) -> Any:
    """Helper function to extract from value analysis
        depending if the application uses a global or local variables
        a different function is needed."""
    
    try:
        res = obj.value.get_initializer().get()
    except AttributeError:
        res = obj.value.get()
    return res

class XEN(OSBase):
    """OS Model for Xen Hypervisor"""
    
    # Number of guest systems
    system_count: int = 0

    # Guest specific data, numbered by how they are added in json config
    # OS of guest
    system_types: list[OSBase] = []
    # CFG of guest
    cfg_list: list[CFG] = []
    # Instancegraph of guest
    instances_list: list[InstanceGraph] = []
    # Graph datastructure of guest
    graph_list: list[Graph] = []

    # Used for output in printer
    irq_ids: dict[int, int] = {}
    
    @staticmethod
    def merge_states(states: list[OSState]) -> OSState:
        """Combines multiple state into one, changes ids to ascending numbers"""

        cpus: list[CPU] = []
        for idx, s in enumerate(states):
            # TODO add support for multicore guests
            assert len(s.cpus) == 1, f"Tried to merge state that is already multicore {len(s.cpus)}."
            cpu: CPU = s.cpus.one()
            cpu.id = idx
            cpu.cfg = XEN.cfg_list[idx]
            cpus.append(cpu)

        state = OSState(cpus=CPUList(cpus), cfg=None, instances=None)
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, 
                            instances_list=XEN.instances_list)

        for i, s in enumerate(states):
            # OS specific
            new_context = XEN.system_types[i].move_context(s.context, i)
            for k,v in new_context.items():
                state.context[k] = v

        return state
    
    # ------------------- From OSBase --------------------

    @staticmethod
    def get_initial_state(cfg: CFG, instances: InstanceGraph) -> OSState:
        """Creates the inital state over all guests, parameters are not used, instead the class 
         attributes cfg_list/instances-list."""

        logger.info(f"Get inital state from {XEN.system_count} systems.")

        states: OSState = []
        for i in range(XEN.system_count):
            states.append(XEN.system_types[i].get_initial_state(cfg=XEN.cfg_list[i], 
                                                            instances=XEN.instances_list[i]))
        return XEN.merge_states(states)
    
    @staticmethod
    def get_cpu_local_contexts(context: dict, cpu_id: int, instances: InstanceGraph) -> dict[Any, Any]:
        """Since every part of the context is already numbered correctly, it is
         extracted from each guest OS."""
        return XEN.system_types[cpu_id].get_cpu_local_contexts(context, cpu_id, instances)

    @staticmethod
    def get_global_contexts(contexts, instances) -> dict[Any, Any]:
        """Get all contexts that affct multiple CPUs."""
        
        global_contexsts = []
        for inst, ctx in contexts.items():
            if not hasattr(inst, "cpu_id"):
                global_contexsts.append((inst, ctx))

        # TODO: might need global contexts from guest OSs, for this use OSState as parameter and not context
        return dict(global_contexsts)

    @staticmethod
    def handle_irq(graph, state, cpu_id, irq):
        """IRQs can be passed to the guest OS."""
        return XEN.system_types[cpu_id].handle_irq(graph, state, cpu_id, irq)

    @staticmethod
    def handle_exit(graph, state, cpu_id):
        """Can be paresed by guest OS."""
        return XEN.system_types[cpu_id].handle_exit(graph, state, cpu_id)

    @staticmethod
    def interpret(graph: Graph, state: OSState, cpu_id, categories=SyscallCategory.every) -> OSState:
        """Parse a system call and direct it to the correct guest OS, returns follow up state. 
         Possible this could also return multiple States with a wierd OS."""

        syscall = state.get_syscall_name(cpu_id)
        # logger.info(f"Interpret: cpu_id: {cpu_id} System count: {XEN.system_count} {XEN.graph_list}\nCurrent graph: {graph}")

        # A Xen syscall is a hypercall
        if XEN.is_syscall(syscall):
            logger.info(f"\33[1;36mSyscall\033[0m: {syscall} on cpu/dom {cpu_id} {state}")

            # Retrieve hypercall function
            syscall_function = getattr(XEN, syscall)

            # If another dom was added via an SP its graph might still be active, so change here
            graph = XEN.graph_list[cpu_id]

            # Execute hypercall
            return syscall_function(graph, state, cpu_id)
        else:
            # Syscall from the guest OS are parsed there
            return XEN.system_types[cpu_id].interpret(graph=XEN.graph_list[cpu_id], state=state, cpu_id=cpu_id, categories=categories)

    @staticmethod
    def schedule(state: OSState, cpus=None) -> None:
        """Perform scheduling operating on a possible multicore/OS state, state is modifed in place.
         Since the scheduling is only local, a multi-OS state is scheduled locally on each OS."""

        if cpus is None:
            cpus = [cpu.id for cpu in state.cpus]

        if len(cpus) == 1:
            # For one CPU find the right one and only schedule it
            for idx, cfg in enumerate(XEN.cfg_list):
                if cfg == state.cfg:
                    logger.info(f"Scheduling on cpu: {idx}.")
                    XEN.system_types[idx].schedule(state=state, cpus=cpus)
                    break
        else:
            logger.info(f"Scheduling a xen multicore cpu with: {cpus} cores.")

            sc_states = []
            # Split multicore state into singlecore states
            for _, state in get_single_core_states(multi_core_state=state, os=XEN).items():
                sc_states.append(state)

            # Schedule each state, works because sc_states contains linked/shallow copy of state
            for sc_state in sc_states:
                idx = sc_state.cpus.one().id
                XEN.system_types[idx].schedule(state=sc_state, cpus=cpus)        
    


    # ------------------- Special Methods --------------------

    @staticmethod
    def add_interrupts(state: OSState) -> None:
        """The way fake interupt cores are added in the MultiSSE does not work for virtualized systems
         The input state is modifed by adding any required interupt cores, byiterate over all systems and 
         finding each local interrupts"""
        cpu_idx = max([x.id for x in state.cpus]) + 1

        tmp_instances_list = []
        # Care to not iterate an extending list
        for idx, instances in enumerate(XEN.instances_list):

            for _, irq in instances.get(IRQ):

                # TODO: Xen IRQs are not needed for now!
                if XEN.system_types[idx] != AUTOSAR:
                    logger.warning("Zephyr's IRQs are ignored for now!")
                    continue

                # every irq gets an own CPU
                ctx = state.context[irq]
                if ctx.status == TaskStatus.running:
                    exec_state = CrossExecState.computation
                    cur_abb = ctx.abb
                else:
                    exec_state = CrossExecState.idle
                    cur_abb = None
                irq_cpu = IRQCPU(id=cpu_idx, irq=irq, reference_cpu_id=irq.cpu_id, irq_on=False,
                                control_instance=instances.get_node(irq), abb=cur_abb, 
                                call_path=copy(ctx.call_path), exec_state=exec_state, analysis_context=None,
                                cfg=XEN.cfg_list[idx])
                state.cpus[irq_cpu.id] = irq_cpu
                # reassign irq
                irq.cpu_id = irq_cpu.id
                cpu_idx += 1
                
                XEN.cfg_list.append(XEN.cfg_list[idx])
                XEN.graph_list.append(XEN.graph_list[idx])
                XEN.system_types.append(XEN.system_types[idx])
                XEN.system_count += 1
                XEN.irq_ids[irq.cpu_id] = idx

                # Move IRQ-Handler/ISR
                XEN.system_types[idx].move_irqhandler(irq, XEN.instances_list[idx], idx)

                tmp_instances_list.append(XEN.instances_list[idx])

        XEN.instances_list += tmp_instances_list

    # @staticmethod
    # def find_system_id(state: OSState):
    #     """Unused helper function"""
    #     for idx, cfg in enumerate(XEN.cfg_list):
    #         if cfg == state.cfg:
    #             logger.info(f"Scheduling on cpu: {idx}.")



    # --------------------------- New Hypercalls ---------------------

    # Used to assign unique ids
    _eventchannel_id: int = 0

    @syscall(categories={SyscallCategory.comm}, 
            signature=(Arg("remote_dom", ty=int, raw_value=True, hint=SigType.value),
                        Arg("channel", ty=int, raw_value=True, hint=SigType.value),
                        Arg("cb", ty=CrossOSEvent, hint=SigType.symbol)),)
    def XEN_wrap_evtchn_alloc_unbound(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        
        remote_dom = read_va_integer(args.remote_dom)
        channel = read_va_integer(args.channel)
        cb: str = args.cb.value.get_name()

        masked = False
        task = XEN.system_types[cpu_id].find_cross_os_event(state=state, cpu_id=cpu_id, cb=cb)
        if not task:
            logger.info(f"CrossOSEvent {channel} has no task for \"{cb}\" on dom-{cpu_id}, it is masked")
            masked = True

        # TODO: check if channel already exists
        XEN._eventchannel_id += 1
        evtchn = EventChannel(name="Evtchn-"+str(XEN._eventchannel_id), cpu_id=cpu_id, source_domain=cpu_id, target_domain=remote_dom,
                              channel=channel, event=task, masked=masked, pending=False)
        state.context[evtchn] = 1

        return state
    


    @syscall(categories={SyscallCategory.comm},
            signature=(Arg("remote_dom", ty=int, raw_value=True, hint=SigType.value),
                        Arg("channel", ty=int, raw_value=True, hint=SigType.value),
                        Arg("cb", ty=CrossOSEvent, hint=SigType.symbol),),)
    def XEN_wrap_evtchn_bind_interdomain(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        
        # remote_dom = args.remote_dom.value.get_initializer().get()
        # channel = args.channel.value.get_initializer().get()
        remote_dom = read_va_integer(args.remote_dom)
        channel = read_va_integer(args.channel)
        cb: str = args.cb.value.get_name()

        masked = False
        task = XEN.system_types[cpu_id].find_cross_os_event(state=state, cpu_id=cpu_id, cb=cb)
        if not task:
            logger.info(f"CrossOSEvent {channel} has no task for \"{cb}\" on dom-{cpu_id}, it is masked")
            masked = True

        # TODO: check if channel already exists
        XEN._eventchannel_id += 1
        evtchn = EventChannel(name="Evtchn-"+str(XEN._eventchannel_id), cpu_id=cpu_id, source_domain=cpu_id, target_domain=remote_dom,
                              channel=channel, event=task, masked=masked, pending=False)
        state.context[evtchn] = 1

        return state
    
    def get_remote_id(state: OSState, id: int) -> None:
        """
        Check, if the cpu/dom id is already in state, otherwise raise a CrossCoreAction,
            which return here again with the other dom/cpu. Analog to os.Autosar.check_cpu.
        """
        ids = set([x.id for x in state.cpus])

        if id not in ids:
            raise CrossCoreAction(set([id]))
            
    @syscall(categories={SyscallCategory.comm}, 
            signature=(Arg("channel", ty=int, raw_value=True, hint=SigType.value),),)
    def XEN_wrap_evtchn_send(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:

        # If we are not hypervised this does nothing
        if graph.os != XEN:
            return state
        
        # Retrieve active event-channels of sender
        channel_id = read_va_integer(args.channel)
        active_channels = state.context_get_instances(EventChannel)
        for evtchn in active_channels:
            if channel_id == evtchn.channel:
                sender_channel = evtchn
                break
        if not sender_channel:
            logger.warning(f"Wrap_evtchn_send do not has an evtchn for channel: {channel_id}")
            return state

        if sender_channel.target_domain >= XEN.system_count:
            logger.warning(f"Wrap_evtchn_send for a domain that does not exist: {channel_id}")
            logger.warning("Hypercall is ignored!")
            return state
        
        # Raise CrossCoreAction to get receiver and return here again
        XEN.get_remote_id(state, sender_channel.target_domain)
        # Convert state in hyersse state
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, instances_list=XEN.instances_list)

        # Find EventChannel object from receiver
        combined_channels = state.context_get_instances(EventChannel)
        receiver_channel = None
        for evtchn in combined_channels:
            if evtchn.cpu_id == sender_channel.target_domain and evtchn.channel == channel_id and evtchn.target_domain == cpu_id:
                receiver_channel = evtchn
                break
        if not receiver_channel:
            logger.warning(f"Wrap_evtchn_send's does not find the right channel: {channel_id} at the receiver")
            logger.warning("Hypercall is ignored!")
            return state
        
        if receiver_channel.masked:
            if receiver_channel.pending:
                logger.info(f"Receiver: {receiver_channel.cpu_id} masked interrupts from {channel_id}. It was already pending.")
            else:
                logger.info(f"Receiver: {receiver_channel.cpu_id} masked interrupts from {channel_id}. It is now pending.")
                receiver_channel.pending = True
            return state

        elif not receiver_channel.event:
            logger.warning(f"Wrap_evtchn_send Receiver's event has no event, but it is not masked.")
            logger.warning("Hypercall is ignored!")
            return state
        
        else:
            # Trigger event
            logger.info(f"Receiver: {receiver_channel.cpu_id} received send on {channel_id} from {receiver_channel.target_domain}.")
            state.cfg = XEN.cfg_list[receiver_channel.cpu_id]
            return XEN.system_types[receiver_channel.cpu_id].trigger_cross_os_event(state, receiver_channel.cpu_id, receiver_channel.event)
            # return state

    @syscall(categories={SyscallCategory.comm}, 
            signature=(Arg("channel", ty=int, raw_value=True, hint=SigType.value),),)
    def XEN_wrap_evtchn_poll(graph: Graph, state: OSState, cpu_id: int, args, va) -> OSState:
        """ Query if an event occured on this channel. This is usefull for CrossOSEvents that do not trigger an new task, but are required to be polled."""
        
        # If we are not hypervised this does nothing, TODO: value analyzer should return false
        if graph.os != XEN:
            return state
        
        # Retrieve active event-channels of receiver
        channel_id = read_va_integer(args.channel)
        active_channels = state.context_get_instances(EventChannel)
        for evtchn in active_channels:
            if channel_id == evtchn.channel:
                receiver_channel = evtchn
                break
        if not receiver_channel:
            logger.warning(f"Wrap_evtchn_poll do not has an evtchn for channel: {channel_id}")
            logger.warning("Hypercall is ignored!")
            return state

        if receiver_channel.target_domain >= XEN.system_count:
            logger.warning(f"Wrap_evtchn_poll for a domain that does not exist: {channel_id}")
            logger.warning("Hypercall is ignored!")
            return state

        # Raise CrossCoreAction to get receiver and return here again
        XEN.get_remote_id(state, receiver_channel.target_domain)
        # Convert state in hyersse state
        state.hypersse_state(system_count=XEN.system_count, cfg_list=XEN.cfg_list, instances_list=XEN.instances_list)

        if receiver_channel.pending:
            logger.info(f"Found pending event on channel: {channel_id}")
            receiver_channel.pending = False

            # if there is an CrossOSEvent trigger it
            if receiver_channel.event:
                state.cfg = XEN.cfg_list[receiver_channel.cpu_id]
                return XEN.system_types[receiver_channel.cpu_id].trigger_cross_os_event(state, receiver_channel.cpu_id, receiver_channel.event)
            else:
                # TODO: here we know if an event was pending or not, but can not further use the information in the analysis.
                # idealy we could hint the value analyzer if we found an event or not
                return state

        else: 
            logger.info(f"No pending event on {channel_id}")
            # TODO: here we know if an event was pending or not, but can not further use the information in the analysis.
            # idealy we could hint the value analyzer if we found an event or not
            return state

        
# --------------------------- Classes ---------------------

@dataclass()
class EventChannel(CPUBounded):
    """Event channels are used bidirectional, but because each system gets an instance of this class."""
    def __eq__(self, other):
        return self.name == other.name

    def __hash__(self):
        return hash(self.__class__.__name__ + self.name)
    
    name: str
    source_domain: int
    target_domain: int
    channel: int
    event: CrossOSEvent | None  # event that happens on hypercall

    # used with a CrossOSEvent of None
    masked: bool
    pending: bool

    def __str__(self):
        s = f"\33[1;36m{self.name}\033[0m: cpu_id={self.cpu_id} dom-{self.source_domain} to dom-{self.target_domain},"\
             f" via channel: {self.channel}, event: {self.event}, masked: {self.masked}, pending: {self.pending}"
        return s
