#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2022 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test, fail_if

import json
import graph_tool
import sys

from graph_tool import GraphView
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


def _dump(reduced, core_map, timings=False):
    dump = {"vertices": {}, "edges": []}
    for v in reduced.vertices():
        dump["vertices"][str(int(v))] = core_map[v]
    for e in reduced.edges():
        if timings:
            dump["edges"].append({"src": str(int(e.source())),
                                  "tgt": str(int(e.target())),
                                  "bcet": reduced.ep.bcet[e],
                                  "wcet": reduced.ep.wcet[e]})
        else:
            dump["edges"].append((str(int(e.source())), str(int(e.target()))))
    return json.dumps(dump, indent=2)


def _build_graph(data, timings=False):
    g = graph_tool.Graph()
    core_map = g.new_vp("int32_t")
    if timings:
        g.ep["bcet"] = g.new_ep("int64_t")
        g.ep["wcet"] = g.new_ep("int64_t")
    v_map = {}

    for v_id, core_count in data["vertices"].items():
        v = g.add_vertex()
        core_map[v] = core_count
        v_map[v_id] = v

    for edge in data["edges"]:
        if timings:
            e = g.add_edge(v_map[edge["src"]], v_map[edge["tgt"]])
        else:
            e = g.add_edge(v_map[edge[0]], v_map[edge[1]])
        if timings:
            g.ep.bcet[e] = edge["bcet"]
            g.ep.wcet[e] = edge["wcet"]

    return g, core_map


def _add_debug_config(config):
    """Add debug related config."""
    debug = {"enabled": False,  # set this to True to enable debug logs/dumps
             "extra_steps": ["DumpCFG", "DumpCallgraph", "DumpInstances"],
             "extra_config": {
                 "MultiSSE": {"dump": True, "log_level": "debug",
                              "per_round_dump": True,
                              "log_single_core_transitions": True},
                 "CreateABBs": {"dump": True, "log_level": "debug"},
                 "LoadOIL": {"dump": True, "log_level": "debug"},
                 "logger": {"AUTOSAR": "debug"}}}
    if debug["enabled"]:
        config["steps"] += debug["extra_steps"]
        e_conf = debug["extra_config"]
        for key in e_conf.keys():
            if key in config:
                config[key] = {**config[key], **e_conf[key]}
            else:
                config[key] = e_conf[key]


def main():
    """Test for correct MultiSSE execution."""
    with_timings = len(sys.argv) > 4
    inp = {"oilfile": lambda argv: argv[3]}
    if with_timings:
        config = {"steps": ["ApplyTimings", "LockElision"],
                  "MultiSSE": {"with_times": True}}
        inp["timings"] = lambda argv: argv[4]
    else:
        config = {"steps": ["LockElision"]}
    _add_debug_config(config)
    print(config)
    data = init_test(extra_config=config, extra_input=inp, os_name="AUTOSAR")

    mstg = data.graph.mstg
    reduced = mstg.vertex_type(StateType.entry_sync, StateType.exit_sync)
    reduced.vp["cores"] = _get_core(mstg, reduced)

    # do a graph copy, isomorphism will fail otherwise
    reduced = graph_tool.Graph(reduced, prune=True)

    print(_dump(reduced, reduced.vp["cores"], timings=with_timings),
          file=sys.stderr)

    golden, correct_cores = _build_graph(data.data, timings=with_timings)

    if len(data.data["vertices"]) == 1 and len(data.data["edges"]) == 0:
        if len(list(reduced.vertices())) == 1:
            if len(list(reduced.edges())) == 0:
                return
    fail_if(len(data.data["vertices"]) == 0, "No vertices")
    is_isomorph, iso_map = isomorphism(reduced, golden, reduced.vp["cores"],
                                       correct_cores, isomap=True)
    fail_if(not is_isomorph, "Not isomorph")
    if with_timings:
        fs = GraphView(reduced,
                       efilt=reduced.ep.type.fa == MSTType.follow_sync)
        for e in fs.edges():
            other = golden.edge(iso_map[e.source()], iso_map[e.target()],
                                all_edges=True)
            if fs.ep.bcet[e] > 0:
                fail_if(all([fs.ep.bcet[e] != golden.ep.bcet[o]
                             for o in other]),
                        "BCET not equal")
            if fs.ep.wcet[e] > 0:
                fail_if(all([fs.ep.wcet[e] != golden.ep.wcet[o]
                             for o in other]),
                        "WCET not equal")


if __name__ == '__main__':
    main()
