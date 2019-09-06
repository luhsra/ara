#!/usr/bin/env python3.6
import graph
import json

from graph import CFType

from init_test import init_test, fail_if


def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(['ICFG'])
    abbs = m_graph.new_graph.abbs()
    icf_edges = []
    for edge in filter(lambda x: x.type == CFType.icf, abbs.edges()):
        icf_edges.append([hash(edge.source()), hash(edge.target())])
    fail_if(data != sorted(icf_edges), "Data not equal")


if __name__ == '__main__':
    main()
