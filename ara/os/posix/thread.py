from ara.os.os_base import ControlInstance
import pyllco
from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg, assign_id, UnknownArgument, DefaultArgument, LikelyArgument
from .posix_utils import IDInstance, assign_instance_to_argument, logger, register_instance, add_edge_from_self_to, get_running_thread, add_interaction_edge, is_soc_unique 
from .system_profiles import Profile

@dataclass(eq = False)
class Thread(IDInstance, ControlInstance):
    function_name: str                  # Name of entry function
    sched_priority: int                 # The priority of this thread.
    sched_policy: str                   # The scheduling policy [SCHED_FIFO, SCHED_RR, ...].
    inherited_sched_attr: bool          # Thread inherited scheduling attributes from creating thread.
    
    last_setname_np_value: str = None   # Last value of a pthread_setname_np() call on this thread.
                                        # Used to determine whether a second call leads to ambiguous thread name.

    wanted_attrs = ["name", "sched_priority", "sched_policy", "inherited_sched_attr", "function_name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

# Scheduling policies supported by musl libc.
SCHEDULING_POLICIES = dict({
    (0, 'SCHED_OTHER'),
    (1, 'SCHED_FIFO'),
    (2, 'SCHED_RR'),
    (3, 'SCHED_BATCH'),
    (5, 'SCHED_IDLE'),
    (6, 'SCHED_DEADLINE'),
})

UNKNOWN = UnknownArgument(exception=None, value=None)

class ThreadSyscalls:

    # A dict containing all entry points without __ara_fake_entry as keys.
    # Map entry_point -> Thread object
    # This dict allows us to detect multiple threads with the same entry point. 
    entry_points = dict()

    def _get_value(value):
        """Get the value of UnknownArgument, DefaultArgument or LikelyArgument objects.
        
        If value is not of the types above simply return value.
        """
        return value if not type(value) in (UnknownArgument, DefaultArgument, LikelyArgument) else value.value

    # int pthread_create(pthread_t *restrict thread,
    #                    const pthread_attr_t *restrict attr,
    #                    void *(*start_routine)(void*), void *restrict arg);
    @syscall(aliases={"__pthread_create"},
             categories={SyscallCategory.create},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('attr', hint=SigType.instance, ty=pyllco.ConstantPointerNull),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg')))
    def pthread_create(graph, state, cpu_id, args, va):

        cfg = graph.cfg

        # Detect Thread Attribute fields
        sched_priority=Profile.get_value("default_sched_priority")
        sched_policy=Profile.get_value("default_sched_policy")
        inherited_sched_attr=Profile.get_value("default_inheritsched")
        if type(args.attr) != pyllco.ConstantPointerNull:
            logger.warning("pthread_create(): ThreadAttr used. We can not detect this object so all fields related to it are now <unknown>")
            sched_priority=UNKNOWN
            sched_policy=UNKNOWN
            inherited_sched_attr=UNKNOWN

        # Handling for the case that we can not get the start_routine argument.
        if type(args.start_routine) != pyllco.Function:
            new_thread = Thread(cpu_id=-1,
                                cfg=cfg,
                                artificial=True,
                                function=None,
                                function_name=UnknownArgument(),
                                sched_priority=sched_priority,
                                sched_policy=sched_policy,
                                inherited_sched_attr=inherited_sched_attr,
                                name=None
            )
            logger.warning(f"pthread_create(): Could not get entry point for the new Thread {new_thread.name}.")
            state = register_instance(new_thread, f"{ThreadSyscalls._get_value(new_thread.name)}", graph, cpu_id, state)
            assign_instance_to_argument(va, args.thread, new_thread)
            return state
        
        func_name = args.start_routine.get_name()

        # Create the new thread.
        new_thread = Thread(cpu_id=-1,
                            cfg=cfg,
                            artificial=False,
                            function=cfg.get_function_by_name(func_name),
                            function_name=func_name,
                            sched_priority=sched_priority,
                            sched_policy=sched_policy,
                            inherited_sched_attr=inherited_sched_attr,
                            name=None
        )
        state = register_instance(new_thread, f"{new_thread.name} ({func_name})", graph, cpu_id, state)
        assign_instance_to_argument(va, args.thread, new_thread)

        # Handle the creation of multiple threads with the same entry point.
        # TODO: make this better:
        if func_name in ThreadSyscalls.entry_points.keys():
            logger.warning(f"pthread_create(): There is already an thread with the entry point {func_name}. I do not analyse the entry point again.")
            # Add info edge:
            add_interaction_edge(state.instances, new_thread, ThreadSyscalls.entry_points[func_name], "Info: Same entry point as")
            new_thread.artificial = True
        else:
            ThreadSyscalls.entry_points[func_name] = new_thread

        return state


    # int pthread_join(pthread_t thread, void **value_ptr);
    @syscall(aliases={"__pthread_join"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),
                        Arg('value_ptr', hint=SigType.symbol)))
    def pthread_join(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_join()", cpu_id)

    # int pthread_detach(pthread_t thread);
    @syscall(aliases={"__pthread_detach"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),))
    def pthread_detach(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_detach()", cpu_id)

    # int pthread_cancel(pthread_t thread);
    @syscall(aliases={"__pthread_cancel"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),))
    def pthread_cancel(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_cancel()", cpu_id)