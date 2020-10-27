from .os_util import syscall, get_argument
from .os_base import OSBase
from ara.util import get_logger
from ara.graph import SyscallCategory, SigType
from dataclasses import dataclass
import ara.graph as _graph
import pyllco

logger = get_logger("ZEPHYR")

@dataclass
class Thread:
    # Pointer to uninitialized struct k_thread.
    data: object
    # Pointer to the stack space.
    stack: object
    # Stack size in bytes.
    stack_size: int
    # Thread entry function.
    entry: object
    # 3 parameters that are passed to the entry function.
    entry_params: [object]
    # Thread priority.
    priority: int
    # Thread options.
    options: int
    # Scheduling delay, or K_NO_WAIT (for no delay).
    delay: int

class ZEPHYR(OSBase):
    vertex_properties = [('label', 'string', 'instance name'),
                         ('obj', 'object', 'instance object (e.g. Task)'),
                         ('test', 'string', 'Something'),
                         ]
    edge_properties = [('label', 'string', 'syscall name')]

    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def init(state):
        for prop in ZEPHYR.vertex_properties:
            state.instances.vp[prop[0]] = state.instances.new_vp(prop[1])
        for prop in ZEPHYR.edge_properties:
            state.instances.ep[prop[0]] = state.instances.new_ep(prop[1])

    @staticmethod
    def interpret(cfg, abb, state, categories=SyscallCategory.every):
        syscall = cfg.get_syscall_name(abb)
        logger.info(f"Interpreting syscall: {syscall}")
        return getattr(ZEPHYR, syscall)(cfg, abb, state)

    @syscall(categories={SyscallCategory.create},
             signature=(SigType.symbol, SigType.symbol, SigType.value,
                        SigType.symbol, SigType.value, SigType.value,
                        SigType.value, SigType.value, SigType.value,
                        SigType.value))
    def k_thread_create(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Thread"

        data = get_argument(cfg, abb, state.call_path, 0, ty=pyllco.Value)
        stack = get_argument(cfg, abb, state.call_path, 1, ty=pyllco.Value)
        stack_size = get_argument(cfg, abb, state.call_path, 2)
        entry = get_argument(cfg, abb, state.call_path, 3, ty=pyllco.Function)
        p1 = get_argument(cfg, abb, state.call_path, 4)
        p2 = get_argument(cfg, abb, state.call_path, 5)
        p3 = get_argument(cfg, abb, state.call_path, 6)
        entry_params = [p1, p2, p3]
        priority = get_argument(cfg, abb, state.call_path, 7)
        options = get_argument(cfg, abb, state.call_path, 8)
        delay = get_argument(cfg, abb, state.call_path, 9)

        t = Thread(
            data,
            stack,
            stack_size,
            entry,
            entry_params,
            priority,
            options,
            delay
        )

        state.instances.vp.obj[v] = t

        logger.info(f"Created new thread {t}")
        state.next_abbs = []

        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

        return state

    @syscall
    def k_sem_take(cfg, abb, state):
        state = state.copy()
        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Semaphore"
        state.next_abbs = []

        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())

        return state