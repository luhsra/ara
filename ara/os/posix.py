from .os_util import syscall, get_argument, get_return_value, assign_id
from .os_base import OSBase

import pyllco
import functools
import html

import ara.graph as _graph
from ara.graph import CallPath, SyscallCategory, SigType
from ara.util import get_logger
from ara.steps.util import current_step

from dataclasses import dataclass

logger = get_logger("POSIX")


@dataclass
class POSIXInstance(object):
    cfg: any
    abb: any
    call_path: any
    name: str


@dataclass
class Task(POSIXInstance):
    pass
    # TODO: add more values

    def as_dot(self):
        pass

@dataclass
class Thread(POSIXInstance):
    threadID: int
    priority: int
    sched_policy: str
    floating_point_env: any # TODO: check type
    partOfTask: Task = None

    def as_dot(self):
        wanted_attrs = ["name", "function", "priority"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                    for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }


class POSIX(OSBase):
    
    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        pass

    @staticmethod
    def interpret(cfg, abb, state, categories=SyscallCategory.every):
        """interprets a detected syscall"""

        syscall = cfg.get_syscall_name(abb)
        logger.debug(f"Get syscall: {syscall}, ABB: {cfg.vp.name[abb]}"
                     f" (in {cfg.vp.name[cfg.get_function(abb)]})")

        syscall_function = getattr(POSIX, syscall)

        if isinstance(categories, SyscallCategory):
            categories = set((categories,))

        if SyscallCategory.every not in categories:
            sys_cat = syscall_function.categories
            if sys_cat | categories != sys_cat:
                # do not interpret this syscall
                state = state.copy()
                state.next_abbs = []
                POSIX.add_normal_cfg(cfg, abb, state)
                return state

        return getattr(POSIX, syscall)(cfg, abb, state)

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())


    ##############################################
    ###            --- Syscalls ---           ####


    @syscall(categories={SyscallCategory.create})
    def pause(cfg, abb, state):
        logger.debug("found pause() syscall")

        state = state.copy()

        cp = state.call_path
        #ticks = get_argument(cfg, abb, cp, 0)

        #if state is None or state.running is None:
            # TODO proper error handling
        #    logger.error("ERROR: pause() called without running Thread")

        #e = state.instances.add_edge(state.running, state.running)
        #state.instances.ep.label[e] = "pause()"

        #state.next_abbs = []
        POSIX.add_normal_cfg(cfg, abb, state)
        return state