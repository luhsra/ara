if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
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
    callgraph = graph.callgraph
    cfg = graph.cfg
    call_edges = []
    for edge in callgraph.edges():
        call_edges.append([get_func_name(callgraph, cfg, edge.source()),
                           get_func_name(callgraph, cfg, edge.target())])

    print(sorted(call_edges))
    fail_if(data != sorted(call_edges), f"Data not equal for os={os}")
