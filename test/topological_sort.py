#!/usr/bin/env python3.6

import json
import stepmanager
import graph
import sys

from native_step import Step


def main():
    g = graph.PyGraph()
    os_name = sys.argv[1]
    json_file = sys.argv[2]
    i_file = sys.argv[3]
    print("Testing with", i_file, "and json:", json_file, "and os: ", os_name)
    with open(json_file) as f:
        data = json.load(f)

    config = {'os': os_name,
              'input_files': [i_file]}
    p_manager = stepmanager.StepManager(g, config)

    p_manager.execute(['ValidationStep'])

    functions  = g.get_type_vertices("Function")
    
    for json_function in data:
        
        expected_order = [] 
        
        for abb in data[json_function]:
            expected_order.append(abb)
        
        for graph_function in functions:
                
            if graph_function.get_name() == json_function:
                
                function_abbs = graph_function.get_atomic_basic_blocks()
                function_order = []
                
                for abb in function_abbs:
                    function_order.append(abb.get_name())
                    
                assert len(function_order) == len(expected_order)
                for should, have in zip(function_order, expected_order):
                    assert should == have
                    
                break


        
        
    


if __name__ == '__main__':
    main()
