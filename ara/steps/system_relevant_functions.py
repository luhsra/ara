"""Container for SystemRelevantFunction."""
from ara.graph import Graph
from .step import Step
from .os import get_os_syscalls

from graph_tool import GraphView
from graph_tool.topology import transitive_closure


class SystemRelevantFunctions(Step):
    """Mark all function that are in the Callgraph as system relevant or not."""

    def get_single_dependencies(self):
        return ["CallGraph", "SysFuncts"]

    def run(self):
        if self._graph.os is None:
            self._log.warn("No OS detected. This step is meaningless then.")
            return

        syscalls = get_os_syscalls(self._graph.os)
        callgraph = self._graph.callgraph

        tc = transitive_closure(GraphView(callgraph, reversed=True))

        # syscalls are always entry points
        for syscall, _ in syscalls:
            cg_node = callgraph.get_node_with_name(syscall)
            if cg_node is None:
                continue

            # syscalls are always system relevant
            callgraph.vp.system_relevant[cg_node] = True
            for node in tc.vertex(cg_node).out_neighbors():
                callgraph.vp.system_relevant[callgraph.vertex(node)] = True

        if self.dump.get():
            dump_prefix = self.dump_prefix.get()
            assert dump_prefix
            uuid = self._step_manager.get_execution_id()
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": dump_prefix + f'{uuid}.dot',
                 "graph_name": 'System relevant functions',
                 "subgraph": 'callgraph'}
            )
