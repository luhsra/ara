#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2023 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json
import os.path

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct instance detection."""
    config = {"steps": ["SIA", "DumpCFG", "DumpInstances"]}
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
                assert(val != 0)
                continue
            if name == 'soc':
                continue
            if prop.value_type() == 'python::object':
                # for now, just ignore
                # val = str(val)
                continue
            i_dump[name] = val
        dump.append(i_dump)

    # data.log.warn(json.dumps(sorted(dump, key=lambda x: x['id']), indent=2))
    fail_if(data.data != sorted(dump, key=lambda x: x['id']), "Data not equal")


if __name__ == '__main__':
    main()
