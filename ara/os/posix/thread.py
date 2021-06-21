import pyllco
from dataclasses import dataclass, field
from typing import Any
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, logger, register_instance, do_not_interpret_syscall, add_edge_from_self_to

# SIA and InteractionAnalysis requires a Hash for the Thread/Task instance.
# We provide an id based implementation and allow the class to be mutable.
# Make sure to not alter the num_id field of a Thread.
@dataclass(eq = False)
class Thread(IDInstance):
    entry_abb: Any
    function: pyllco.Function
    attr: Any
    arg: Any
    is_regular: bool = True # Always True if this thread is not the main thread.

    wanted_attrs = ["name", "function", "attr", "arg", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#6fbf87",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

    def __hash__(self):
        return hash(self.num_id)


class ThreadSyscalls:

    # A set of all entry points without __ara_fake_entry.
    # This set allows us to detect multiple threads with the same entry point. 
    entry_points = set()

    # int pthread_create(pthread_t *restrict thread,
    #                    const pthread_attr_t *restrict attr,
    #                    void *(*start_routine)(void*), void *restrict arg);
    @syscall(aliases={"__pthread_create"},
             categories={SyscallCategory.create},
             signature=(Arg('thread', hint=SigType.instance),
                        Arg('attr', hint=SigType.symbol),
                        Arg('start_routine', hint=SigType.symbol, ty=pyllco.Function),
                        Arg('arg', hint=SigType.symbol)))
    def pthread_create(graph, abb, state, args, va):

        # Handling for the case that we can not get the start_routine argument.
        if args.start_routine == None:
            new_thread = Thread(entry_abb=None,
                                function=None,
                                attr=args.attr,
                                arg=args.arg,
                                name=None,
                                is_regular=False
            )
            args.thread = new_thread
            logger.warning(f"Could not get entry point for the new Thread {new_thread.name}.")
            return register_instance(new_thread, f"{new_thread.name}", graph, abb, state)

        # Avoid the creation of multiple threads with the same entry point.
        func_name = args.start_routine.get_name()
        if func_name in ThreadSyscalls.entry_points:
            logger.warning(f"There is already an thread with the entry point {func_name}. Ignore this thread for now.")
            return do_not_interpret_syscall(graph, abb, state)
        ThreadSyscalls.entry_points.add(func_name)
        
        # Create the new thread.
        new_thread = Thread(entry_abb=graph.cfg.get_entry_abb(graph.cfg.get_function_by_name(func_name)),
                            function=func_name,
                            attr=args.attr,
                            arg=args.arg,
                            name=None
        )
        args.thread = new_thread
        return register_instance(new_thread, f"{new_thread.name} ({func_name})", graph, abb, state)


    # int pthread_join(pthread_t thread, void **value_ptr);
    @syscall(aliases={"__pthread_join"},
             categories={SyscallCategory.comm},
             signature=(Arg('thread', hint=SigType.instance, ty=Thread),
                        Arg('value_ptr', hint=SigType.symbol)))
    def pthread_join(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.thread, "pthread_join()")