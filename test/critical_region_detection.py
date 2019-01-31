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
        warnings = json.load(f)

    config = {'os': os_name,
              'input_files': [i_file]}
    p_manager = stepmanager.StepManager(g, config)

    p_manager.execute(['ValidationStep'])

    val_step = p_manager.get_step('ValidationStep')
    side_data = val_step.get_side_data()

    #TODO ABB3 nicht im kritischen Bereich

    for tmp in side_data:
        print(tmp['location'].get_name())

    assert len(warnings) == len(side_data)
    for should, have in zip(warnings, side_data):
        assert should['type'] == have['type']
        assert should['location'] == have['location'].get_name()


if __name__ == '__main__':
    main()
