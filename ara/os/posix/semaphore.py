import pyllco
from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, register_instance, add_edge_from_self_to

@dataclass(eq = False)
class Semaphore(IDInstance):
    process_shared: bool    # Is the Semaphore available for other processes?
    init_counter: int       # The initial counter state. (e.g. the total amount of managed resources)
    wanted_attrs = ["name", "process_shared", "init_counter", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#00FFFF",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class SemaphoreSyscalls:

    # int sem_init(sem_t *sem, int pshared, unsigned value);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('sem', hint=SigType.instance),
                        Arg('pshared', hint=SigType.value, ty=pyllco.ConstantInt),
                        Arg('value', hint=SigType.value, ty=pyllco.ConstantInt)))
    def sem_init(graph, abb, state, args, va):
        
        proc_shared = None
        if args.pshared != None:
            proc_shared = True if args.pshared.get() > 0 else False

        new_semaphore = Semaphore(process_shared=proc_shared,
                                  init_counter=args.value.get() if args.value != None else None,
                                  name=None
        )
        
        args.sem = new_semaphore
        return register_instance(new_semaphore, f"{new_semaphore.name}", graph, abb, state)

    # int sem_wait(sem_t *sem);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('sem', hint=SigType.instance, ty=Semaphore),))
    def sem_wait(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.sem, "sem_wait()")

    # int sem_post(sem_t *sem);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('sem', hint=SigType.instance, ty=Semaphore),))
    def sem_post(graph, abb, state, args, va):
        return add_edge_from_self_to(state, args.sem, "sem_post()")