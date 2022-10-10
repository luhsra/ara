#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if
from common_json_graphs import json_callgraph


def main():
    """Test for correct function pointer mapping."""
    config = {"steps": ["CFGOptimize",
                        "ResolveFunctionPointer",
                        "CallGraphStats"]}
    data = init_test(extra_config=config, logger_name="fpointer")
    callgraph = json_callgraph(data.graph.callgraph)

    # data.log.info(json.dumps(sorted(c_edges), indent=2))
    fail_if(data.data != callgraph, "Data not equal")


if __name__ == '__main__':
    main()
