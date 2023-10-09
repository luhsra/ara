#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test, fail_if_json_not_equal, to_json

import os.path
import sys

from ara.os.freertos import ISR


def main():
    """Test for correct instance detection."""
    config = {"steps": ["SIA"],  # "DumpCFG", "DumpInstances", "DumpCallgraph"],
              "SIA": {"log_level": "debug",
                      "traversal_mode": sys.argv[3]},
              "ISRSearch": {"log_level": "debug"},
              "CreateISR": {"log_level": "debug"},
              "logger": {"StepManager": "info"}}
    data = init_test(extra_config=config)
    instances = data.graph.instances
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    ids = set()
    for instance in instances.vertices():
        i_dump = {}
        obj = instances.vp.obj[instance]
        for name, prop in instances.vp.items():
            val = prop[instance]
            if name == 'file':
                val = os.path.relpath(os.path.realpath(val), start=script_dir)
            if name == 'llvm_soc' and not isinstance(obj, ISR):
                # wild pointer, skip this
                assert val != 0
                continue
            if name == 'id':
                assert val not in ids
                ids.add(val)
                continue
            if name == 'soc':
                continue
            if prop.value_type() == 'python::object':
                # for now, just ignore
                # val = str(val)
                continue
            i_dump[name] = val
        dump.append(i_dump)

    measured_data = sorted(dump, key=lambda x: x['label'])
    fail_if_json_not_equal(data.data, measured_data)


if __name__ == '__main__':
    main()
