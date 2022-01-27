#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if

import json
import logging
import graph_tool
import sys

from graph_tool.topology import isomorphism
from ara.graph import MSTType, StateType


def _get_core(mstg, reduced):
    m2sy = mstg.edge_type(MSTType.m2sy)
    core_map = mstg.new_vp("int32_t")
    for v in reduced.vertices():
        if reduced.vp.type[v] == StateType.entry_sync:
            core_count = m2sy.vertex(v).in_degree()
        elif reduced.vp.type[v] == StateType.exit_sync:
            core_count = m2sy.vertex(v).out_degree()
        else:
            assert False, "Needs to be entry or exit"
        core_map[v] = core_count
    return core_map


def _dump(mstg, reduced, core_map):
    dump = {"vertices": {}, "edges": []}
    for v in reduced.vertices():
        dump["vertices"][str(int(v))] = core_map[v]
    for e in reduced.edges():
        dump["edges"].append((str(int(e.source())), str(int(e.target()))))
    return json.dumps(dump, indent=2)


def _build_graph(data):
    g = graph_tool.Graph()
    core_map = g.new_vp("int32_t")
    v_map = {}

    for v_id, core_count in data["vertices"].items():
        v = g.add_vertex()
        core_map[v] = core_count
        v_map[v_id] = v

    for src, tgt in data["edges"]:
        g.add_edge(v_map[src], v_map[tgt])

    return g, core_map


def main():
    """Test for correct MultiSSE execution."""
    config = {"steps": ["LockElision"]}
    inp = {"oilfile": lambda argv: argv[3]}
    m_graph, data, log, _ = init_test(extra_config=config, extra_input=inp)

    mstg = m_graph.mstg
    reduced = mstg.vertex_type(StateType.entry_sync, StateType.exit_sync)
    reduced.vp["cores"] = _get_core(mstg, reduced)

    # do a graph copy, isomorphism will fail otherwise
    reduced = graph_tool.Graph(reduced, prune=True)

    # print(_dump(mstg, reduced, reduced.vp["cores"]), file=sys.stderr)

    golden, correct_cores = _build_graph(data)

    fail_if(len(data["vertices"]) == 0 or
            not isomorphism(reduced, golden, reduced.vp["cores"], correct_cores))


if __name__ == '__main__':
    main()
