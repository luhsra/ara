#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if

from graph_tool.search import bfs_iterator

import json
import sys


def _node_iter(graph, source):
    yield source
    visited = set([source])
    for e in bfs_iterator(graph, source=source):
        tgt = e.target()
        if tgt not in visited:
            visited.add(tgt)
            yield tgt


def _dump_trace(trace):
    lines = ',\n'.join([f"  {json.dumps(x)}" for x in trace])
    print(f"[\n{lines}\n]", file=sys.stderr)


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
    trace = []

    for v in _node_iter(sstg, start):
        state = sstg.vp.state[v]
        cpu = state.cpus[0]
        if cpu.control_instance:
            instance = state.instances.vp.label[state.instances.vertex(cpu.control_instance)]
            syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
            if syscall != "":
                trace.append([syscall, instance, str(cpu.call_path)])
        else:
            trace.append("Idle")

    for line in trace:
        log.debug(line)

    # _dump_trace(trace)
    fail_if(data != trace)


if __name__ == '__main__':
    main()
