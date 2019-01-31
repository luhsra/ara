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

    functions = g.get_type_vertices("Function")

    for func in functions:
        func_order = [x.get_name() for x in func.get_atomic_basic_blocks()]
        assert(len(func_order) == len(data[func.get_name()]))
        for should, have in zip(func_order, data[func.get_name()]):
            assert should == have


if __name__ == '__main__':
    main()
