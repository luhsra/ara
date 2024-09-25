#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

import os.path
import json

# Note: init_test must be imported first
from init_test import fail_if_json_not_equal, init_test


def main():
    """Test for correct interaction detection."""
    config = {"steps": ["InteractionAnalysis"],
              "SIA": {"log_level": "debug"},
              "InteractionAnalysis": {"log_level": "debug"},
              "logger": {"StepManager": "info", "FreeRTOS": "debug"}}
    data = init_test(extra_config=config)
    instances = data.graph.instances
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    for instance in instances.vertices():
        i_dump = {}
        for name, prop in instances.vp.items():
            val = prop[instance]
            if name == 'file':
                val = os.path.relpath(os.path.realpath(val), start=script_dir)
            if name == 'llvm_soc':
                # wild pointer, skip this
                continue
            if name == 'soc':
                # pointer to vertex index
                continue
            if prop.value_type() == 'python::object':
                # for now, just ignore
                # val = str(val)
                continue
            i_dump[name] = val
        i_dump["type"] = "instance"
        dump.append(i_dump)
    for edge in instances.edges():
        i_dump = {
            "source": instances.vp.id[edge.source()],
            "target": instances.vp.id[edge.target()],
        }
        for name, prop in instances.ep.items():
            if name == 'syscall' or name == 'number':
                # pointer to vertex index
                continue
            val = prop[edge]
            i_dump[name] = val
        i_dump["type"] = "interaction"
        dump.append(i_dump)

    def sort_key(item):
        if item['type'] == "instance":
            return "0" + item['id']
        else:
            return "1" + json.dumps(item, sort_keys=True)
        return "1"

    dump = sorted(dump, key=sort_key)

    # with open(data.data_file, "w") as f:
    #     json.dump(dump, f, indent=2, sort_keys=True)
    fail_if_json_not_equal(data.data, dump)


if __name__ == '__main__':
    main()
