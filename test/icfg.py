#!/usr/bin/env python3.6
import json

from ara.graph import CFType

from init_test import init_test, fail_if


def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(steps=["ICFG"])
    cfg = m_graph.cfg
    icf_edges = []
    for edge in filter(lambda x: cfg.ep.type[x] == CFType.icf, cfg.edges()):
        icf_edges.append([hash(edge.source()),
                          hash(edge.target())])
    fail_if(data != sorted(icf_edges), "Data not equal")


if __name__ == '__main__':
    main()
