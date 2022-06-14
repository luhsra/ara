#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if

import json
import difflib
import sys


def _dump_trace(trace):
    ns = ',\n'.join([f"    {json.dumps(x)}" for x in trace["vertices"]])
    es = ',\n'.join([f"    {json.dumps(x)}" for x in trace["edges"]])
    return f'{{\n  "vertices": [\n{ns}\n  ],\n  "edges": [\n{es}\n  ]\n}}\n'


def _get_trace(sstg, v):
    state = sstg.vp.state[v]
    cpu = state.cpus[0]
    if cpu.control_instance:
        syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
        instance = state.instances.vp.label[state.instances.vertex(cpu.control_instance)]
        if syscall != "":
            return (syscall, instance, str(cpu.call_path))
    else:
        return ("Idle",)
    start = sstg.vertex(sstg.gp.start)
    if v == start:
        return ("Start",)
    assert(False)


def _to_tuple(t):
    return tuple(map(_to_tuple, t)) if isinstance(t, (list, tuple)) else t


def main():
    """Test for correct SSE execution."""
    config = {"steps": ["LoadOIL",
                        "DumpCFG",
                        "ReduceSSTG"]}
    inp = {"oilfile": lambda argv: argv[3]}
    data = init_test(extra_config=config, extra_input=inp)

    sstg = data.graph.reduced_sstg

    trace = {}
    verts = []
    for vertex in sstg.vertices():
        verts.append((_get_trace(sstg, vertex), vertex))

    verts.sort(key=lambda x: x[0])

    states = [(idx, obj, vert) for idx, (obj, vert) in enumerate(verts)]
    trace["vertices"] = tuple([(idx, obj) for idx, obj, _ in states])

    edge_map = dict([(vert, idx) for idx, _, vert in states])

    edges = []
    for e in sstg.edges():
        src = edge_map[e.source()]
        tgt = edge_map[e.target()]
        edges.append((src, tgt))
    trace["edges"] = tuple(sorted(edges))

    dt = _dump_trace(trace)
    print(dt, file=sys.stderr)
    with open(sys.argv[1]) as f:
        golden_trace = f.readlines()
    sys.stderr.writelines(difflib.unified_diff(golden_trace, dt.splitlines(True)))

    fail_if(_to_tuple(data.data["vertices"]) != trace["vertices"])
    fail_if(_to_tuple(data.data["edges"]) != trace["edges"])


if __name__ == '__main__':
    main()
