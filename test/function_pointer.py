#!/usr/bin/env python3
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from common_json_graphs import json_callgraph
from ara.graph import CFType


def main():
    """Test for correct function pointer mapping."""
    config = {"steps": ["CFGOptimize",
                        "IRWriter",
                        "ResolveFunctionPointer",
                        "CallGraphStats"]}
    m_graph, data, _ = init_test(extra_config=config)
    c_edges = json_callgraph(m_graph.callgraph)

    # log.info(json.dumps(c_edges, indent=2))
    fail_if(data != c_edges, "Data not equal")


if __name__ == '__main__':
    main()
