from .os_util import syscall, assign_id, Arg
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
    entry_abb: any
    function: any
    threadID: int
    priority: int
    sched_policy: str
    floating_point_env: any # TODO: check type
    partOfTask: Task

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

    def get_maximal_id(self):
        # TODO: use a better max_id
        return '.'.join(map(str, ["Thread",
                                  self.name,
                                  self.function,
                                  self.priority,
                                 ]))


class POSIX(OSBase):
    
    @staticmethod
    def get_special_steps():
        return []

    @staticmethod
    def has_dynamic_instances():
        return True

    @staticmethod
    def init(state):
        state.scheduler_on = True  # The Scheduler is always on in POSIX.

    @staticmethod
    def interpret(graph, abb, state, categories=SyscallCategory.every):
        """interprets a detected syscall"""

        cfg = graph.cfg
        logger.debug("interpret called")

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

        return getattr(POSIX, syscall)(graph, abb, state)

    def handle_soc(state, v, cfg, abb,
                   branch=None, loop=None, recursive=None, scheduler_on=None,
                   usually_taken=None):
        instances = state.instances

        def b(c1, c2):
            if c2 is None:
                return c1
            else:
                return c2

        in_branch = b(state.branch, branch)
        in_loop = b(state.loop, loop)
        is_recursive = b(state.recursive, recursive)
        logger.debug("scheduler " + str(state.scheduler_on)) # TODO: fix scheduler off issue
        after_sched = b(state.scheduler_on, scheduler_on)
        is_usually_taken = b(state.usually_taken, usually_taken)

        instances.vp.branch[v] = in_branch
        instances.vp.loop[v] = in_loop
        instances.vp.recursive[v] = is_recursive
        instances.vp.after_scheduler[v] = after_sched
        instances.vp.usually_taken[v] = is_usually_taken
        instances.vp.unique[v] = not (is_recursive or in_branch or in_loop)
        instances.vp.soc[v] = abb
        instances.vp.llvm_soc[v] = cfg.vp.llvm_link[cfg.get_single_bb(abb)]
        instances.vp.file[v] = cfg.vp.file[abb]
        instances.vp.line[v] = cfg.vp.line[abb]

    @staticmethod
    def add_normal_cfg(cfg, abb, state):
        for oedge in cfg.vertex(abb).out_edges():
            if cfg.ep.type[oedge] == _graph.CFType.lcf:
                state.next_abbs.append(oedge.target())


    ##############################################
    ###            --- Syscalls ---           ####


    @syscall(categories={SyscallCategory.create})
    def pause(graph, abb, state, args, va):
        logger.debug("found pause() syscall")

        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Thread"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        POSIX.handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = Thread(graph.cfg, abb=None, call_path=None, name="Test thread",
                                        entry_abb = None,
                                        function = None,
                                        threadID = 3,
                                        priority = 2,
                                        sched_policy = None,
                                        floating_point_env = None, # TODO: check type
                                        partOfTask = None
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state