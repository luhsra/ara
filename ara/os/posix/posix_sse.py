
from logging import Logger
from typing import Type
from ara.graph.graph import Graph
from ara.graph.mix import SyscallCategory
from ara.os.os_base import OSState
from ara.os.posix.posix import POSIX
from ara.steps.cfg_traversal import Visitor, run_sse

class PosixSSE:
    attrib_object_type = None
    def _buildVisitor(state: OSState):
        state_set = set({state})
        class PosixSSEVisitor(Visitor):
            PREVENT_MULTIPLE_VISITS = True
            SYSCALL_CATEGORIES = (SyscallCategory.create)

            @staticmethod
            def get_initial_state():
                return state

            @staticmethod
            def schedule(new_states):
                return new_states
            
            @staticmethod
            def add_state(new_state):
                if new_state not in state_set:
                    state_set.add(new_state)
                    return True
                return False

            @staticmethod
            def add_transition(source, target):
                return

        return PosixSSEVisitor()

    def is_running():
        return issubclass(PosixSSE.attrib_object_type, Type)

    def spawn(attrib_object_type: Type, graph: Graph, state: OSState, logger: Logger):
        visitor = PosixSSE._buildVisitor(state)
        PosixSSE.attrib_object_type = attrib_object_type
        run_sse(
            graph=graph,
            os=POSIX,
            visitor=visitor,
            logger=logger,
        )
        PosixSSE.attrib_object_type = None