#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if
from common_json_graphs import json_callgraph

import json
import difflib
import sys


def _nl_split(content):
    return [f"{x}\n" for x in content.strip('\n').split('\n')]


def main():
    """Test for correct function pointer mapping."""
    config = {"steps": ["CFGOptimize",
                        "ResolveFunctionPointer",
                        "CallGraphStats"],
              "ResolveFunctionPointer": {"log_level": "debug"}}
    data = init_test(extra_config=config, logger_name="fpointer")
    callgraph = json_callgraph(data.graph.callgraph)

    golden = json.dumps(data.data, indent=2)
    current = json.dumps(callgraph, indent=2)
    sys.stderr.writelines(difflib.unified_diff(_nl_split(golden),
                                               _nl_split(current)))
    # sys.stderr.writelines(current + "\n")
    fail_if(data.data != callgraph, "Data not equal")


if __name__ == '__main__':
    main()
