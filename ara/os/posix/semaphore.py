import pyllco
from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, assign_instance_to_argument, register_instance, add_edge_from_self_to

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
    def sem_init(graph, state, cpu_id, args, va):
        
        proc_shared = None
        if type(args.pshared) == pyllco.ConstantInt:
            proc_shared = True if args.pshared.get() > 0 else False

        new_semaphore = Semaphore(process_shared=proc_shared,
                                  init_counter=args.value.get() if type(args.value) == pyllco.ConstantInt
                                                                else "<unknown>",
                                  name=None
        )
        
        state = register_instance(new_semaphore, new_semaphore.name, "sem_init()", graph, cpu_id, state)
        assign_instance_to_argument(va, args.sem, new_semaphore)
        return state

    # int sem_wait(sem_t *sem);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('sem', hint=SigType.instance, ty=Semaphore),))
    def sem_wait(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.sem, "sem_wait()", cpu_id, expected_instance='Semaphore')

    # int sem_post(sem_t *sem);
    @syscall(categories={SyscallCategory.comm},
             signature=(Arg('sem', hint=SigType.instance, ty=Semaphore),))
    def sem_post(graph, state, cpu_id, args, va):
        return add_edge_from_self_to(state, args.sem, "sem_post()", cpu_id, expected_instance='Semaphore')