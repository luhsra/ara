#!/usr/bin/env python3.6
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import ABBType, CFGView


def main():
    """Test for correct value analysis recognition."""
    config = {"steps": ["ValueAnalysis", {"name": "ValueAnalysis",
                                          "entry_point": "main"}]}
    m_graph, data, _ = init_test(extra_config=config)
    cfg = m_graph.cfg
    syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)

    for syscall in syscalls.vertices():
        print(syscalls.vp.name[syscall])
        args = syscalls.vp.arguments[syscall]

        for argument in args:
            for call_path, value in argument.items():
                print(call_path.print(m_graph.callgraph, functions=True), value)


    # icf_edges = []
    # for edge in filter(lambda x: cfg.ep.type[x] == CFType.icf, cfg.edges()):
    #     icf_edges.append([hash(edge.source()),
    #                       hash(edge.target())])
    # fail_if(data != sorted(icf_edges), "Data not equal")


if __name__ == '__main__':
    main()
