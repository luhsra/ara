#!/usr/bin/env python3

from enum import IntEnum
from init_test import init_test, fail_if_json_not_equal
from ara.os.os_util import UnknownArgument, DefaultArgument, LikelyArgument
import json
import os
import sys

def json_instance_graph(instances, edge_type_class: IntEnum):
    """Instance Graph -> JSON Instance Graph
    
    Arguments:
    instances:          instance graph
    edge_type_class:    Enum that contains all edge types.
                        This Enum is used to convert the edge type to a printable string.
                        To provide this object create it in your main os model object.
                        This enum is optional. Set it to None if you do not want to use it.

    Make sure that all instances have wanted_attrs (arguments of interest) field.
    It is recommended to use instances of type AutoDotInstance (see os/os_util.py).
    """
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    # Instances
    for instance_v in instances.vertices():
        i_dump = {}
        for name, prop in instances.vp.items():
            val = prop[instance_v]
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
        instance = instances.vp.obj[instance_v]
        # Add all other instance specific attributes.
        assert hasattr(instance, "wanted_attrs"), f"instance {instance.__class__.__name__} does not have a wanted_attrs field!"
        for attr in sorted(instance.wanted_attrs):
            val = getattr(instance, attr)
            if val == None or type(val) in (bool, str, int, float):
                i_dump[attr] = val
            elif type(val) in (list, tuple, range, set, frozenset):
                i_dump[attr] = sorted(val)
            elif type(val) == dict:
                i_dump[attr] = dict(sorted(val.items()))
            elif type(val) in (UnknownArgument, DefaultArgument, LikelyArgument):
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
            if name not in ["syscall", # ignore "syscall" field. This field is too dependent of ABB graph.
                            "quantity"]: # ignore "quantity" field. This field is not visible in the instance graph.
                i_dump[name] = prop[edge]
        if edge_type_class is not None:
            i_dump["type"] = edge_type_class(i_dump["type"]).name
        # 0 := no type is set
        elif i_dump["type"] == 0:
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
    
    arguments: instance_graph.py <expected json graph> <LLVM IR file> <OS>(optional) <step setting file>(optional)

    <OS> := Set this argument to the name of the used os model (e.g. FreeRTOS, ZEPHYR, POSIX).
    Write '-' if you do not want to set this argument.

    This script accepts an extra shell argument to set the ARA step settings. 
    If this argument is not set, it will default to the default of the used OS model.

    If the JSON file (sys.argv[1]) is not existing, this script will auto generate it with the provided LLVM IR.
    In this case, this test is no test case anymore but a useful script to generate a JSON Instance Graph.
    """
    self_is_testcase = True
    json_file = sys.argv[1]
    if not os.path.isfile(json_file):
        print(f"JSON file {json_file} does not exists. This testcase is now no testcase anymore.")
        print("This script will autogenerate the JSON file.")
        self_is_testcase = False
        with open(json_file, "w") as f:
            f.write("[]") # Just a placeholder

    # Load Settings
    DEFAULT_SETTING_FILE = "default_instance_graph_config.json"
    DEFAULT_SETTING_FILE_OS = {
        "POSIX": "posix_test/settings/posix_default.json",
        "ZEPHYR": "zephyr_test/settings/zephyr_default.json",
    }
    os_name = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '-' else None
    setting_file = sys.argv[4] if len(sys.argv) > 4 else path_next_to_self_file(DEFAULT_SETTING_FILE_OS.get(os_name) if os_name in DEFAULT_SETTING_FILE_OS else DEFAULT_SETTING_FILE)
    with open(setting_file, "r") as f:
        config = json.load(f)
    
    data = init_test(extra_config=config, extra_input=None, os_name=os_name)
    m_graph = data.graph
    data = data.data
    dump = json_instance_graph(m_graph.instances, m_graph.os.EdgeType if hasattr(m_graph.os, "EdgeType") else None)
    
    if self_is_testcase:
        fail_if_json_not_equal(data, dump)
    else:
        with open(json_file, "w") as f:
            f.write(json.dumps(dump, indent=2))
        print("Created file " + json_file)
        print("Make sure to manually validate its content.")


if __name__ == '__main__':
    main()
