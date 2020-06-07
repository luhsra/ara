#!/usr/bin/env python3.6
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import CFType


def main():
    """Test for correct icfg mapping."""
    config = {"steps": ["ICFG", {"name": "ICFG",
                                 "entry_point": "_Z14other_functioni"}]}
    m_graph, data, _ = init_test(extra_config=config)
    cfg = m_graph.cfg
    icf_edges = []
    for edge in filter(lambda x: cfg.ep.type[x] == CFType.icf, cfg.edges()):
        icf_edges.append([hash(edge.source()),
                          hash(edge.target())])
    fail_if(data != sorted(icf_edges), "Data not equal")


if __name__ == '__main__':
    main()
