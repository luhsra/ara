#!/usr/bin/env python3.6
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import CFType


def main():
    """Test for correct recursive function deptection."""
    config = {"steps": ["RecursiveFunctions"]}
    m_graph, data, _ = init_test(extra_config=config)
    callgraph = m_graph.callgraph

    nodes = []
    for v in callgraph.vertices():
        nodes.append([callgraph.vp.function_name[v],
                      bool(callgraph.vp.recursive[v])])

    # print(json.dumps(sorted(nodes), indent=2))
    fail_if(data != sorted(nodes), "Data not equal")


if __name__ == '__main__':
    main()
