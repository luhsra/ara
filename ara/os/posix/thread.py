from os import stat
import pyllco
from dataclasses import dataclass, field
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg, assign_id
from .posix_utils import IDInstance, POSIXInstance, logger, register_instance, add_edge_from_self_to, get_running_thread, add_interaction_edge, is_soc_unique, Unknown, NotSet, Likely 

@dataclass(eq = False)
class Thread(IDInstance):
    entry_abb: Any                      # The entry point as abb type
    function: pyllco.Function           # The entry point as function type
    sched_priority: int                 # The priority of this thread.
    sched_policy: str                   # The scheduling policy [SCHED_FIFO, SCHED_RR, ...].
    inherited_sched_attr: bool          # Thread inherited scheduling attributes from creating thread.
    is_regular: bool = True             # True if this thread should be analyzed by an algorithm in sse.py (e.g. SIA).
    last_setname_np_value: str = None   # Last value of a pthread_setname_np() call on this thread. Used to determine whether a second leads to ambiguous thread name 

    wanted_attrs = ["name", "sched_priority", "sched_policy", "inherited_sched_attr", "function", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

@dataclass(eq = False)
class ThreadAttr:
    sched_priority: int
    sched_policy: str
    inheritsched: bool
    name: str
    unique: bool

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
        return value if not type(value) in (Unknown, NotSet, Likely) else value.value

    # int pthread_create(pthread_t *restrict thread,
    #                    const pthread_attr_t *restrict attr,
    #                    void *(*start_routine)(void*), void *restrict arg);
    @syscall(aliases={"__pthread_create"},
             categories={SyscallCategory.create},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('attr', hint=SigType.instance, ty=[ThreadAttr, pyllco.ConstantPointerNull]),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg')))
    def pthread_create(graph, abb, state, args, va):

        # Detect Thread Attribute fields
        sched_priority = NotSet()
        sched_policy = NotSet()
        inherited_sched_attr = NotSet()
        thread_name = NotSet()
        if args.attr != None and type(args.attr) == ThreadAttr:
            threadattr = args.attr
            thread_name = threadattr.name
            inherited_sched_attr = threadattr.inheritsched
            if type(inherited_sched_attr) == bool and inherited_sched_attr:
                threadattr = get_running_thread(state) # Duck typing -> Use sched_prio and policy from current thread instead.
            sched_priority = threadattr.sched_priority
            sched_policy = threadattr.sched_policy
        if type(thread_name) == Likely:
            logger.warning(f"pthread_create(): The name of the thread {thread_name.value} is not ensured. pthread_attr_setname_np() call is not unique.")

        # Handling for the case that we can not get the start_routine argument.
        if args.start_routine == None:
            new_thread = Thread(entry_abb=None,
                                function=None,
                                sched_priority=sched_priority,
                                sched_policy=sched_policy,
                                inherited_sched_attr=inherited_sched_attr,
                                name=thread_name if not type(thread_name) in (Unknown, NotSet) else None,
                                is_regular=False
            )
            args.thread = new_thread
            logger.warning(f"pthread_create(): Could not get entry point for the new Thread {new_thread.name}.")
            return register_instance(new_thread, f"{ThreadSyscalls._get_value(new_thread.name)}", graph, abb, state)
        
        func_name = args.start_routine.get_name()

        # Create the new thread.
        new_thread = Thread(entry_abb=graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                            function=func_name,
                            sched_priority=sched_priority,
                            sched_policy=sched_policy,
                            inherited_sched_attr=inherited_sched_attr,
                            name=thread_name if not type(thread_name) in (Unknown, NotSet) else None,
        )
        args.thread = new_thread
        state = register_instance(new_thread, ThreadSyscalls._get_value(new_thread.name) if not type(thread_name) in (Unknown, NotSet) else f"{new_thread.name} ({func_name})", graph, abb, state)

        # Handle the creation of multiple threads with the same entry point.
        if func_name in ThreadSyscalls.entry_points.keys():
            logger.warning(f"pthread_create(): There is already an thread with the entry point {func_name}. I do not analyse the entry point again.")
            # Add info edge:
            add_interaction_edge(state.instances, new_thread, ThreadSyscalls.entry_points[func_name], "Info: Same entry point as")
            new_thread.is_regular = False
        else:
            ThreadSyscalls.entry_points[func_name] = new_thread

        return state


    # int pthread_join(pthread_t thread, void **value_ptr);
    @syscall(aliases={"__pthread_join"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),
                        Arg('value_ptr', hint=SigType.symbol)))
    def pthread_join(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_join()")

    # int pthread_detach(pthread_t thread);
    @syscall(aliases={"__pthread_detach"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),))
    def pthread_detach(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_detach()")

    # int pthread_cancel(pthread_t thread);
    @syscall(aliases={"__pthread_cancel"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),))
    def pthread_cancel(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_cancel()")

    # int pthread_attr_init(pthread_attr_t *attr);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance),))
    def pthread_attr_init(graph, abb, state, args, va):
        thread_attr = ThreadAttr(sched_priority=NotSet(),
                                 sched_policy=NotSet(),
                                 inheritsched=NotSet(),
                                 name=NotSet(),
                                 unique=is_soc_unique(state)
        )
        args.attr = thread_attr
        return state

    def _set_attr_option(attr: ThreadAttr, option: str, value, state):

        # Set to likely if soc is not unique
        unique = attr.unique and is_soc_unique(state)
        if not unique and not type(value) in (Unknown, NotSet):
            value = Likely(value)

        setattr(attr, option, value)

    # int pthread_attr_setschedparam(pthread_attr_t *restrict attr,
    #   const struct sched_param *restrict param);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('sched_priority', hint=SigType.value, ty=pyllco.ConstantInt)))
    def ARA_pthread_attr_setschedparam_syscall_(graph, abb, state, args, va): # pthread_attr_setschedparam()
        if args.attr == None or args.sched_priority == None:
            logger.warning(f"pthread_attr_setschedparam(): Could not set thread priority because argument "
                           f"\"{'attr' if args.attr == None else 'sched_priority'}\" is unknown.")
            if args.attr != None:
                args.attr.sched_priority = Unknown()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "sched_priority", args.sched_priority.get(), state)
        return state

    # int pthread_attr_setschedpolicy(pthread_attr_t *attr, int policy);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('policy', hint=SigType.value, ty=pyllco.ConstantInt)))
    def pthread_attr_setschedpolicy(graph, abb, state, args, va):
        if args.attr == None or args.policy == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Could not set scheduling policy because argument "
                           f"\"{'attr' if args.attr == None else 'policy'}\" is unknown.")
            if args.attr != None:
                args.attr.sched_policy = Unknown()
            return state
        sched_policy = SCHEDULING_POLICIES.get(args.policy.get(), None)
        if sched_policy == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Scheduling policy with id {args.attr.sched_policy} is unknown.")
            args.attr.sched_policy = Unknown()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "sched_policy", sched_policy, state)
        return state

    # int pthread_attr_setinheritsched(pthread_attr_t *attr,
    #   int inheritsched);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('inheritsched', hint=SigType.value, ty=pyllco.ConstantInt)))
    def pthread_attr_setinheritsched(graph, abb, state, args, va):
        if args.attr == None or args.inheritsched == None:
            logger.warning(f"pthread_attr_setschedpolicy(): Could not set scheduling policy because argument "
                           f"\"{'attr' if args.attr == None else 'inheritsched'}\" is unknown.")
            if args.attr != None:
                args.attr.inheritsched = Unknown()
            return state
        inheritsched_int = args.inheritsched.get()
        if inheritsched_int == 0: # PTHREAD_INHERIT_SCHED
            ThreadSyscalls._set_attr_option(args.attr, "inheritsched", True, state)
        elif inheritsched_int == 1: # PTHREAD_EXPLICIT_SCHED
            ThreadSyscalls._set_attr_option(args.attr, "inheritsched", False, state)
        else:
            logger.warning(f"pthread_attr_setinheritsched(): Unknown inheritsched attribute with value {inheritsched_int}")
            args.attr.inheritsched = Unknown()
        return state

    # int pthread_attr_setschedpolicy(pthread_attr_t *attr, int policy);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('attr', hint=SigType.instance, ty=ThreadAttr),
                        Arg('name')))
    def pthread_attr_setname_np(graph, abb, state, args, va):
        if args.attr == None or args.name == None:
            logger.warning(f"pthread_attr_setname_np(): Could not set thread name because argument "
                           f"\"{'attr' if args.attr == None else 'name'}\" is unknown.")
            if args.attr != None:
                args.attr.name = Unknown()
            return state
        ThreadSyscalls._set_attr_option(args.attr, "name", args.name, state)
        return state

    # int pthread_setname_np(pthread_t thread, const char *name);
    @syscall(categories={SyscallCategory.create},
            signature=(Arg('thread', hint=SigType.instance, ty=Thread),
                       Arg('name')))
    def pthread_setname_np(graph, abb, state, args, va):
        if args.thread == None or args.name == None:
            logger.warning(f"pthread_setname_np(): Could not set thread name because argument "
                           f"\"{'thread' if args.thread == None else 'name'}\" is unknown.")
            if args.thread != None:
                args.thread.name = Unknown()
                assign_id(state.instances, args.thread.vertex)
            return state

        # Was pthread_setname_np() already called and the current value is different than the value before -> Set name to unknown because we can not distinguish.
        if args.thread.last_setname_np_value != None and args.name != args.thread.last_setname_np_value:
            logger.warning("pthread_setname_np(): ambiguous thread name. pthread_setname_np() is double called.")
            args.thread.name = Unknown()
            assign_id(state.instances, args.thread.vertex)
            return state
        args.thread.last_setname_np_value = args.name
        
        # Set thread name
        name = args.name
        if not is_soc_unique(state):
            name = Likely(name)
        args.thread.name = name
        state.instances.vp.label[args.thread.vertex] = ThreadSyscalls._get_value(name)
        assign_id(state.instances, args.thread.vertex)
        return state