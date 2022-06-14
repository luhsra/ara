#!/usr/bin/env python3
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct function pointer mapping."""
    config = {"steps": ["CFGOptimize",
                        "IRWriter",
                        "ResolveFunctionPointer",
                        "CallGraphStats"]}
    data = init_test(extra_config=config, logger_name="fpointer")
    callgraph = data.graph.callgraph

    c_edges = []
    for edge in callgraph.edges():
        c_edges.append([callgraph.vp.function_name[edge.source()],
                        callgraph.vp.function_name[edge.target()]])


    # data.log.info(json.dumps(sorted(c_edges), indent=2))
    fail_if(data.data != sorted(c_edges), "Data not equal")


if __name__ == '__main__':
    main()
