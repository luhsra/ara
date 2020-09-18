"""Container for SystemRelevantFunction."""
from ara.graph import Graph
from .step import Step
from .os import get_os_syscalls

from graph_tool import GraphView
from graph_tool.topology import label_out_component


class SystemRelevantFunctions(Step):
    """Mark all function that are in the Callgraph as system relevant or not."""

    def get_single_dependencies(self):
        return ["CallGraph", "SysFuncts", "LLVMMap"]

    def run(self):
        if self._graph.os is None:
            self._log.warn("No OS detected. This step is meaningless then.")
            return

        syscalls = get_os_syscalls(self._graph.os)
        callgraph = self._graph.callgraph
        cfg = self._graph.cfg

        # begin with syscalls, they are always entry points
        for syscall, _ in syscalls:
            cg_node = callgraph.get_node_with_name(syscall)
            if cg_node is None:
                continue

            gv = GraphView(callgraph, reversed=True)
            gv.set_vertex_filter(callgraph.vp.system_relevant, inverted=True)

            label_out_component(gv, cg_node,
                                label=callgraph.vp.system_relevant)

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
