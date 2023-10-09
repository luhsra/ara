#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test, fail_if_json_not_equal

import json
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
    assert False


def _to_tuple(t):
    return tuple(map(_to_tuple, t)) if isinstance(t, (list, tuple)) else t


def main():
    """Test for correct SSE execution."""
    config = {"steps": ["LoadOIL",
                        "DumpCFG",
                        "ReduceSSTG",
                        "DumpSSTG",
                        "DumpInstances"],
              "SSE": {"log_level": "debug"},
              "logger": {"AUTOSAR": "debug"}}
    inp = {"oilfile": lambda argv: argv[3]}
    data = init_test(extra_config=config, extra_input=inp, os_name="AUTOSAR")

    sstg = data.graph.reduced_sstg

    trace = {}
    verts = []
    for vertex in sstg.vertices():
        verts.append((_get_trace(sstg, vertex), vertex))

    verts.sort(key=lambda x: x[0])

    states = [(idx, obj, vert) for idx, (obj, vert) in enumerate(verts)]
    trace["vertices"] = tuple([(idx, obj) for idx, obj, _ in states])

    edge_map = {vert: idx for idx, _, vert in states}

    edges = []
    for e in sstg.edges():
        src = edge_map[e.source()]
        tgt = edge_map[e.target()]
        edges.append((src, tgt))
    trace["edges"] = tuple(sorted(edges))

    dt = _dump_trace(trace)
    print(dt, file=sys.stderr)
    fail_if_json_not_equal(data.data, trace)


if __name__ == '__main__':
    main()
