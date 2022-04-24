#!/usr/bin/env python3
import json
import sys
import os.path

# Note: init_test must be imported first
from init_test import fail_if_json_not_equal, init_test


def main():
    """Test for correct instance detection.
    
    arguments: instance_graph_stats.py <expected json stats> <LLVM IR file> <OS>(optional) <step setting file>(optional)
    """
    os_name = sys.argv[3] if len(sys.argv) > 3 and sys.argv[3] != '-' else None
    config = {"steps": ["InstanceGraphStats"], "InstanceGraphStats": {"dump": True}}
    if len(sys.argv) > 4:     
        setting_file = sys.argv[4]
        with open(setting_file, "r") as f:
            config = json.load(f)
    m_graph, expected, log, _ = init_test(extra_config=config, os_name=os_name)

    with open("dumps/InstanceGraphStats.json", "r") as f:
        actual = json.load(f)

    fail_if_json_not_equal(expected, actual)


if __name__ == '__main__':
    main()
