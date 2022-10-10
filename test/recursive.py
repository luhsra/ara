#!/usr/bin/env python3.6
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct recursive function deptection."""
    config = {"steps": ["RecursiveFunctions"]}
    data = init_test(extra_config=config)
    callgraph = data.graph.callgraph

    nodes = []
    for v in callgraph.vertices():
        nodes.append([callgraph.vp.function_name[v],
                      bool(callgraph.vp.recursive[v])])

    # data.log.info(json.dumps(sorted(nodes), indent=2))
    fail_if(data.data != sorted(nodes), "Data not equal")


if __name__ == '__main__':
    main()
