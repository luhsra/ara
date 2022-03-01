#!/usr/bin/env python3

if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import fail_if_json_not_equal, init_test, fail_if
from ..common_json_graphs import json_callgraph
import sys

def get_func_name(callgraph, cfg, node):
    return cfg.vp.name[callgraph.vp.function[node]]

def test_remove_sysfunc_step(drop_llvm_suffix: bool, os_name: str):
    """Test the RemoveSysfuncBody step."""
    print(drop_llvm_suffix)
    config = {"steps": ["IRReader", "CallGraph"],
                "IRReader": {
                    "no_sysfunc_body": True
                },
                "RemoveSysfuncBody": {
                    "drop_llvm_suffix": drop_llvm_suffix
                }
             }
    graph, data, log, _ = init_test(extra_config=config, os_name=os_name)
    call_edges = json_callgraph(graph.callgraph)

    #print(call_edges)
    fail_if_json_not_equal(data, call_edges)
    fail_if(data != call_edges, f"Data not equal for os_name={os_name} and drop_llvm_suffix={drop_llvm_suffix}")

def str_to_bool(string: str):
    return string.lower() in ["true", "1", "y", "yes"]

def main():
    """Test the RemoveSysfuncBody step.
    
    arguments: remove_sysfunc_body.py <expected json> testdata/remove_sysfunc_body_test.ll <drop_llvm_suffix> <OS>(optional)

    <drop_llvm_suffix> := Boolean (True/False). Sets the option drop_llvm_suffix for RemoveSysfuncBody.
    <OS> := Set this argument to the name of the used os model (e.g. FreeRTOS, ZEPHYR, POSIX).
            Do not provide this argument to use auto model detection.
    """
    test_remove_sysfunc_step(drop_llvm_suffix=str_to_bool(sys.argv[3]) if len(sys.argv) > 3 else False,
                             os_name=sys.argv[4] if len(sys.argv) > 4 else None)

if __name__ == '__main__':
    main()
