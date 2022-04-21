#!/usr/bin/env python3
import json
import os.path

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct instance detection."""
    config = {"steps": ["InstanceGraphStats"], "InstanceGraphStats": {"dump": True}}
    m_graph, expected, log, _ = init_test(extra_config=config)

    with open("dumps/InstanceGraphStats.json", "r") as f:
        actual = json.load(f)

    fail_if(expected != actual, "Data not equal")


if __name__ == '__main__':
    main()
