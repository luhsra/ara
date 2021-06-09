#!/usr/bin/env python3

if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
from ..common_json_graphs import json_instance_graph
from ara.os.posix.posix import POSIX
import json
import os
import sys

def path_next_to_self_file(file):
    """Get the real path of the path "file" which is relative to the current file."""
    return os.path.join(os.path.dirname(__file__), file)

def main():
    """Backend to test the Instance Graph of implementation with a LLVM IR file.
    
    This script accepts an extra shell argument to set the ARA step settings. 
    If no extra argument is set, it will default to settings/posix_default.json

    If the JSON file (sys.argv[1]) is not existing this script will auto generate it with the provided LLVM IR.
    In this case, this test is no test case anymore but a useful script to generate a JSON Instance Graph.
    """
    self_is_testcase = True
    json_file = sys.argv[1]
    if not os.path.isfile(json_file):
        print(f"JSON file {json_file} does not exists. This testcase is now no testcase anymore.")
        print("This script will now autogenerate the JSON file.")
        self_is_testcase = False
        with open(json_file, "w") as f:
            f.write("[]") # Just a placeholder

    # Load Settings
    setting_file = sys.argv[3] if len(sys.argv) > 3 else path_next_to_self_file("settings/posix_default.json")
    with open(setting_file, "r") as f:
        config = json.load(f)
    
    m_graph, data, _ = init_test(extra_config=config, os=POSIX)
    dump = json_instance_graph(m_graph.instances)
    
    if self_is_testcase:
        fail_if(data != dump, "Data not equal")
    else:
        with open(json_file, "w") as f:
            f.write(json.dumps(dump, indent=2))
        print("Created file " + json_file)
        print("Make sure to manually validate its content.")


if __name__ == '__main__':
    main()
