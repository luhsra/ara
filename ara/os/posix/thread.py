from os import stat
from ara.os.os_base import ControlInstance
import pyllco
from dataclasses import dataclass
from typing import Any
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

@dataclass(eq = False)
class ThreadAttr:
    sched_priority: int # Scheduling priority
    sched_policy: str   # Scheduling policy
    inheritsched: bool  # Are scheduling parameters inherited from the creating thread?
    name: str           # Thread name
    unique: bool        # Was the pthread_attr_init() call unique?

    def __hash__(self):
        return id(self)

# Scheduling policies supported by musl libc.
SCHEDULING_POLICIES = dict({
    (0, 'SCHED_OTHER'),
    (1, 'SCHED_FIFO'),
    (2, 'SCHED_RR'),
    (3, 'SCHED_BATCH'),
    (5, 'SCHED_IDLE'),
    (6, 'SCHED_DEADLINE'),
})

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
                        Arg('attr', hint=SigType.instance, ty=[ThreadAttr, pyllco.ConstantPointerNull]),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg')))
    def pthread_create(graph, state, cpu_id, args, va):

        cfg = graph.cfg

        # Detect Thread Attribute fields
        sched_priority=Profile.get_value("default_sched_priority")
        sched_policy=Profile.get_value("default_sched_policy")
        inherited_sched_attr=Profile.get_value("default_inheritsched")
        thread_name = DefaultArgument()
        if args.attr != None and type(args.attr) == ThreadAttr:
            threadattr = args.attr
            thread_name = threadattr.name
            inherited_sched_attr = threadattr.inheritsched
            if type(inherited_sched_attr) == bool or type(inherited_sched_attr) == LikelyArgument: 
                if ThreadSyscalls._get_value(inherited_sched_attr):
                    threadattr = get_running_thread(state) # Duck typing -> Use sched_prio and policy from current thread instead.
                sched_priority = threadattr.sched_priority
                sched_policy = threadattr.sched_policy
                # Set scheduling parameter to LikelyArgument if Thread attributes inheritsched is also only LikelyArgument.
                if type(inherited_sched_attr) == LikelyArgument:
                    sched_priority = LikelyArgument(sched_priority) if type(sched_priority) == bool else sched_priority
                    sched_policy = LikelyArgument(sched_policy) if type(sched_policy) == bool else sched_policy
            else:
                sched_priority = UnknownArgument()
                sched_policy = UnknownArgument()
        if type(thread_name) == LikelyArgument:
            logger.warning(f"pthread_create(): The name of the thread {thread_name.value} is not ensured. pthread_attr_setname_np() call is not unique.")

        # Handling for the case that we can not get the start_routine argument.
        if args.start_routine == None:
            new_thread = Thread(cpu_id=-1,
                                cfg=cfg,
                                artificial=True,
                                function=None,
                                function_name=UnknownArgument(),
                                sched_priority=sched_priority,
                                sched_policy=sched_policy,
                                inherited_sched_attr=inherited_sched_attr,
                                name=thread_name if not type(thread_name) in (UnknownArgument, DefaultArgument) else None
            )
            args.thread = new_thread
            logger.warning(f"pthread_create(): Could not get entry point for the new Thread {new_thread.name}.")
            return register_instance(new_thread, f"{ThreadSyscalls._get_value(new_thread.name)}", graph, cpu_id, state)
        
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
                            name=thread_name if not type(thread_name) in (UnknownArgument, DefaultArgument) else None
        )
        state = register_instance(new_thread, ThreadSyscalls._get_value(new_thread.name) if not type(thread_name) in (UnknownArgument, DefaultArgument) else f"{new_thread.name} ({func_name})", graph, cpu_id, state)
        assign_instance_to_argument(va, args.thread, new_thread)

        # Handle the creation of multiple threads with the same entry point.
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

    # int pthread_attr_init(pthread_attr_t *attr);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance),))
    def pthread_attr_init(graph, state, cpu_id, args, va):
        thread_attr = ThreadAttr(sched_priority=Profile.get_value("default_sched_priority"),
                                 sched_policy=Profile.get_value("default_sched_policy"),
                                 inheritsched=Profile.get_value("default_inheritsched"),
                                 name=DefaultArgument(),
                                 unique=is_soc_unique(state)
        )
        args.attr = thread_attr
        return state

    def _set_attr_option(attr: ThreadAttr, option: str, value, state):
        """Set an option into a thread attribute object."""

        # Set to LikelyArgument if soc is not unique
        unique = attr.unique and is_soc_unique(state)
        if not unique and not type(value) in (UnknownArgument, DefaultArgument):
            value = LikelyArgument(value)

        setattr(attr, option, value)

    # int pthread_attr_setschedparam(pthread_attr_t *restrict attr,
    #   const struct sched_param *restrict param);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('sched_priority', hint=SigType.value, ty=pyllco.ConstantInt)))
    def ARA_pthread_attr_setschedparam_syscall_(graph, state, cpu_id, args, va): # pthread_attr_setschedparam()
        if args.attr == None or args.sched_priority == None:
            logger.warning(f"pthread_attr_setschedparam(): Could not set thread priority because argument "
                           f"\"{'attr' if args.attr == None else 'sched_priority'}\" is UnknownArgument.")
            if args.attr != None:
                args.attr.sched_priority = UnknownArgument()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "sched_priority", args.sched_priority.get(), state)
        return state

    # int pthread_attr_setschedpolicy(pthread_attr_t *attr, int policy);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('policy', hint=SigType.value, ty=pyllco.ConstantInt)))
    def pthread_attr_setschedpolicy(graph, state, cpu_id, args, va):
        if args.attr == None or args.policy == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Could not set scheduling policy because argument "
                           f"\"{'attr' if args.attr == None else 'policy'}\" is UnknownArgument.")
            if args.attr != None:
                args.attr.sched_policy = UnknownArgument()
            return state
        sched_policy = SCHEDULING_POLICIES.get(args.policy.get(), None)
        if sched_policy == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Scheduling policy with id {args.attr.sched_policy} is UnknownArgument.")
            args.attr.sched_policy = UnknownArgument()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "sched_policy", sched_policy, state)
        return state

    # int pthread_attr_setinheritsched(pthread_attr_t *attr,
    #   int inheritsched);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('inheritsched', hint=SigType.value, ty=pyllco.ConstantInt)))
    def pthread_attr_setinheritsched(graph, state, cpu_id, args, va):
        if args.attr == None or args.inheritsched == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Could not set scheduling policy because argument "
                           f"\"{'attr' if args.attr == None else 'inheritsched'}\" is UnknownArgument.")
            if args.attr != None:
                args.attr.inheritsched = UnknownArgument()
            return state
        inheritsched_int = args.inheritsched.get()
        if inheritsched_int == 0: # PTHREAD_INHERIT_SCHED
            ThreadSyscalls._set_attr_option(args.attr, "inheritsched", True, state)
        elif inheritsched_int == 1: # PTHREAD_EXPLICIT_SCHED
            ThreadSyscalls._set_attr_option(args.attr, "inheritsched", False, state)
        else:
            logger.warning(f"pthread_attr_setinheritsched(): UnknownArgument inheritsched attribute with value {inheritsched_int}")
            args.attr.inheritsched = UnknownArgument()
        return state

    # int pthread_attr_setschedpolicy(pthread_attr_t *attr, int policy);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('name')))
    def pthread_attr_setname_np(graph, state, cpu_id, args, va):
        if args.attr == None or args.name == None:
            logger.warning(f"pthread_attr_setname_np(): Could not set thread name because argument "
                           f"\"{'attr' if args.attr == None else 'name'}\" is UnknownArgument.")
            if args.attr != None:
                args.attr.name = UnknownArgument()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "name", args.name, state)
        return state

    # int pthread_setname_np(pthread_t thread, const char *name);
    @syscall(categories={SyscallCategory.create},
            signature=(Arg('thread', hint=SigType.instance, ty=Thread),
                       Arg('name')))
    def pthread_setname_np(graph, state, cpu_id, args, va):
        if args.thread == None or args.name == None:
            logger.warning(f"pthread_setname_np(): Could not set thread name because argument "
                           f"\"{'thread' if args.thread == None else 'name'}\" is UnknownArgument.")
            if args.thread != None:
                args.thread.name = UnknownArgument()
                assign_id(state.instances, args.thread.vertex)
            return state

        # Was pthread_setname_np() already called and the current value is different than the value before -> Set name to UnknownArgument because we can not distinguish.
        if args.thread.last_setname_np_value != None and args.name != args.thread.last_setname_np_value:
            logger.warning("pthread_setname_np(): ambiguous thread name. pthread_setname_np() is double called.")
            args.thread.name = UnknownArgument()
            assign_id(state.instances, args.thread.vertex)
            return state
        args.thread.last_setname_np_value = args.name
        
        # Set thread name
        name = args.name
        if not is_soc_unique(state):
            name = LikelyArgument(name)
        args.thread.name = name
        state.instances.vp.label[args.thread.vertex] = ThreadSyscalls._get_value(name)
        assign_id(state.instances, args.thread.vertex)
        return state