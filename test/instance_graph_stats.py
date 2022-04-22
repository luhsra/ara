#!/usr/bin/env python3
import json
import os.path

# Note: init_test must be imported first
from init_test import fail_if_json_not_equal, init_test


def main():
    """Test for correct instance detection."""
    config = {"steps": ["InstanceGraphStats"], "InstanceGraphStats": {"dump": True}}
    m_graph, expected, log, _ = init_test(extra_config=config)

    with open("dumps/InstanceGraphStats.json", "r") as f:
        actual = json.load(f)

    fail_if_json_not_equal(expected, actual)


if __name__ == '__main__':
    main()
