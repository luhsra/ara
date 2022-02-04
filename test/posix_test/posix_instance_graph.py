#!/usr/bin/env python3

if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
from ara.os.posix.posix import POSIX
from ara.os.posix.posix_utils import Unknown, NotSet, Likely
import json
import os
import sys

def json_instance_graph(instances):
    """Instance Graph -> JSON Instance Graph
    
    This graph creation only works with POSIX instances.
    """
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    # Instances
    for instance in instances.vertices():
        i_dump = {}
        for name, prop in instances.vp.items():
            val = prop[instance]
            if name == 'file':
                if not val == 'N/A' and not val == '' and not val == ' ': 
                    val = os.path.relpath(val, start=script_dir)
            if name == 'llvm_soc':
                # wild pointer, skip this
                continue
            if name == 'soc':
                continue
            if name == 'obj':
                # We handle 'obj' below
                continue
            if prop.value_type() == 'python::object':
                val = "<python_object>"
            i_dump[name] = val
        i_dump["type"] = "instance"
        posix_instance = instances.vp.obj[instance]
        # Add all other instance specific attributes.
        for attr in sorted(posix_instance.wanted_attrs):
            val = getattr(posix_instance, attr)
            if val == None or type(val) in (bool, str, int, float):
                i_dump[attr] = val
            elif type(val) in (list, tuple, range, set, frozenset):
                i_dump[attr] = sorted(val)
            elif type(val) == dict:
                i_dump[attr] = dict(sorted(val.items()))
            elif type(val) in (Unknown, NotSet, Likely):
                i_dump[attr] = str(val)
            else:
                i_dump[attr] = f"<Object: {val.__class__.__name__}>"
        dump.append(i_dump)
    
    # Interactions
    for edge in instances.edges():
        i_dump = {
            "source": instances.vp.id[edge.source()],
            "target": instances.vp.id[edge.target()],
        }
        for name, prop in instances.ep.items():
            val = prop[edge]
            i_dump[name] = val
        i_dump["type"] = "interaction"
        dump.append(i_dump)

    def sort_key(item):
        if item['type'] == "instance":
            return "0" + item['id']
        return "1"

    return sorted(dump, key=sort_key)


def path_next_to_self_file(file):
    """Get the real path of the path "file" which is relative to the current file."""
    return os.path.join(os.path.dirname(__file__), file)


def main():
    """Backend to test the Instance Graph of the implementation with a LLVM IR file.
    
    This script accepts an extra shell argument to set the ARA step settings. 
    If no extra argument is set, it will default to settings/posix_default.json

    If the JSON file (sys.argv[1]) is not existing, this script will auto generate it with the provided LLVM IR.
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
    
    m_graph, data, log, _ = init_test(extra_config=config, os_name="POSIX")
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
