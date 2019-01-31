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

    abbs = g.get_type_vertices("ABB")

    for should in data:

        abb = should['location']

        for tmp_abb in abbs:

            if tmp_abb is not None and tmp_abb.get_name() == abb:
                #print(tmp_abb.get_start_scheduler_relation())
                #print(graph.start_scheduler_relation["after"])


                if not tmp_abb.get_loop_information():
                    print(abb,"current loop relation", tmp_abb.get_loop_information() ,"expected loop relation",True)
                    sys.exit()


if __name__ == '__main__':
    main()
