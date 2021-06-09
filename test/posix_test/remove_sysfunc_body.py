#!/usr/bin/env python3

if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
from ..common_json_graphs import json_callgraph
import json

def get_func_name(callgraph, cfg, node):
    return cfg.vp.name[callgraph.vp.function[node]]

def test_remove_sysfunc_step(os):
    """Test the RemoveSysfuncBody step."""
    config = {"steps": ["IRReader", "CallGraph"],
                "IRReader": {
                    "no_sysfunc_body": True
                }
             }
    graph, data, _ = init_test(extra_config=config, os=os)
    call_edges = json_callgraph(graph.callgraph)

    #print(call_edges)
    fail_if(data != call_edges, f"Data not equal for os={os}")
