#!/usr/bin/env python3
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import CFType


def main():
    """Test for correct function pointer mapping."""
    config = {"steps": ["CFGOptimize",
                        "IRWriter",
                        "ResolveFunctionPointer",
                        "CallGraphStats"]}
    m_graph, data, _ = init_test(extra_config=config)
    callgraph = m_graph.callgraph

    c_edges = []
    for edge in callgraph.edges():
        c_edges.append([callgraph.vp.function_name[edge.source()],
                        callgraph.vp.function_name[edge.target()]])


    # print(json.dumps(sorted(c_edges), indent=2))
    fail_if(data != sorted(c_edges), "Data not equal")


if __name__ == '__main__':
    main()
