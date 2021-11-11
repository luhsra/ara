"""Container for ReduceSSTG."""
from .step import Step

from graph_tool import GraphView


class ReduceSSTG(Step):
    """Throw away all states that are no syscalls."""

    def get_single_dependencies(self):
        return ["SSE"]

    def _is_important(self, sstg, v):
        start = sstg.vertex(sstg.gp.start)
        if v == start:
            return True
        state = sstg.vp.state[v]
        cpu = state.cpus[0]
        if cpu.control_instance:
            syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
            if syscall != "":
                return True
        else:
            return True
        return False

    def run(self):
        sstg = self._graph.sstg

        sstg.vp.reduced = sstg.new_vp("bool", val=False)

        todo_v = sstg.new_vp("bool", val=True)

        vertices = [v for v in sstg.vertices()]

        for v in vertices:
            reduced_sstg = GraphView(sstg, vfilt=todo_v)

            if self._is_important(sstg, v):
                sstg.vp.reduced[v] = True
            else:
                new_edges = set()
                reduced_v = reduced_sstg.vertex(v)
                for in_v in reduced_v.in_neighbors():
                    if in_v != reduced_v:
                        for out_v in reduced_v.out_neighbors():
                            new_edges.add((in_v, out_v))
                for src, tgt in new_edges:
                    # query edge so it is only created if it is _not_ existing
                    sstg.edge(sstg.vertex(src), sstg.vertex(tgt),
                              add_missing=True)
                todo_v[v] = False

        self._graph.reduced_sstg = GraphView(sstg, vfilt=sstg.vp.reduced)

        if self.dump.get():
            self._step_manager.chain_step(
                {
                    "name": "Printer",
                    "dot": self.dump_prefix.get() + "reduced_sstg.dot",
                    "graph_name": "Reduced SSTG",
                    "subgraph": "reduced_sstg",
                }
            )
