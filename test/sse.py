#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if

from graph_tool.search import DFSVisitor, dfs_search
from graph_tool.topology import min_spanning_tree
from graph_tool import GraphView

import json
import sys


def _dump_trace(trace):
    ns = ',\n'.join([f"    {json.dumps(x)}" for x in trace["vertices"]])
    es = ',\n'.join([f"    {json.dumps(x)}" for x in trace["edges"]])
    print(f'{{\n  "vertices": [\n{ns}\n  ],\n  "edges": [\n{es}\n  ]\n}}',
          file=sys.stderr)


def main():
    """Test for correct SSE execution."""
    config = {"steps": ["LoadOIL",
                        {
                            "name": "Printer",
                            "dot": "cfg.dot",
                            "from_entry_point": False,
                            "graph_name": "CFG",
                            "subgraph": "abbs"
                        },
                        "SSE"]}
    inp = {"oilfile": lambda argv: argv[3]}
    m_graph, data, log, _ = init_test(extra_config=config, extra_input=inp)

    sstg = m_graph.sstg
    start = sstg.vertex(sstg.gp.start)

    tree_map = min_spanning_tree(sstg, root=start)
    sstg_tree = GraphView(sstg, efilt=tree_map)

    new_edges = []
    syscall_edge_map = sstg.new_ep("bool", val=False)
    syscall_vert_map = sstg.new_vp("bool", val=False)
    trace_map = sstg.new_vp("object")

    syscall_vert_map[start] = True
    trace_map[start] = ("Init",)

    class SysCallVisitor(DFSVisitor):
        def __init__(self, root):
            self.root = root
            self.last_syscall = None

        def _is_important(self, v):
            state = sstg.vp.state[v]
            cpu = state.cpus[0]
            if cpu.control_instance:
                syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
                instance = state.instances.vp.label[state.instances.vertex(cpu.control_instance)]
                syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
                if syscall != "":
                    return (syscall, instance, str(cpu.call_path))
            else:
                return ("Idle",)
            return None

        def discover_vertex(self, v):
            result = self._is_important(v)
            if result is not None:
                trace_map[v] = result
                syscall_vert_map[v] = True
                if self.last_syscall is None:
                    new_edges.append((self.root, v))
                else:
                    new_edges.append((self.last_syscall, v))
                self.last_syscall = v

        def tree_edge(self, e):
            if e.source() == self.root:
                self.last_syscall = None

    dfs_search(sstg_tree, start, SysCallVisitor(start))

    for source, target in new_edges:
        e = sstg.add_edge(sstg.vertex(source), sstg.vertex(target))
        syscall_edge_map[e] = True

    reduced_sstg = GraphView(sstg,
                             efilt=syscall_edge_map,
                             vfilt=syscall_vert_map)

    trace = {}

    states = []
    for v in reduced_sstg.vertices():
        obj = trace_map[sstg.vertex(v)]
        states.append((obj, v))

    states.sort(key=lambda x: x[0])

    states = [(idx, obj, vert) for idx, (obj, vert) in enumerate(states)]
    trace["vertices"] = tuple([(idx, obj) for idx, obj, _ in states])

    edge_map = dict([(vert, idx) for idx, _, vert in states])

    edges = []
    for e in reduced_sstg.edges():
        src = edge_map[e.source()]
        tgt = edge_map[e.target()]
        edges.append((src, tgt))
    trace["edges"] = tuple(edges)

    for v in trace["vertices"]:
        log.debug(v)

    for e in trace["edges"]:
        log.debug(e)

    def to_tuple(t):
        return tuple(map(to_tuple, t)) if isinstance(t, (list, tuple)) else t

    # _dump_trace(trace)

    fail_if(to_tuple(data["vertices"]) != trace["vertices"])
    fail_if(to_tuple(data["edges"]) != trace["edges"])


if __name__ == '__main__':
    main()
