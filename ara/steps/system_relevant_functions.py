"""Container for SystemRelevantFunction."""
from ara.graph import Graph, SyscallCategory
from ara.os import get_os_syscalls
from .step import Step

from graph_tool import GraphView
from graph_tool.topology import label_out_component


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

        every_set = {SyscallCategory.every, }

        # begin with syscalls, they are always entry points
        for syscall, cls in syscalls:
            sys_func = getattr(cls, syscall)
            for sys_cat in every_set | getattr(cls, syscall).categories:
                cg_node = callgraph.get_node_with_name(syscall)
                if cg_node is None:
                    continue

                gv = GraphView(callgraph, reversed=True)
                # TODO: triggers a SEGFAULT
                # old_sys_rel = gv.copy_property(gv.vp.system_relevant)
                # gv.set_vertex_filter(old_sys_rel, inverted=True)
                vprop = callgraph.vp["syscall_category_" + sys_cat.name]
                label_out_component(gv, cg_node, label=vprop)

        if self.dump.get():
            self._step_manager.chain_step(
                {"name": "Printer",
                 "dot": self.dump_prefix.get() + 'dot',
                 "graph_name": 'System relevant functions',
                 "subgraph": 'callgraph'}
            )
