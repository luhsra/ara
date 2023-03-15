#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json
import os.path

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct instance detection."""
    config = {"steps": [{"name": "LLVMMap", "source_loc": "all"}]}
    data = init_test(extra_config=config)
    dump = []
    bbs = data.graph.bbs

    script_dir = os.path.dirname(os.path.realpath(__file__))

    for bb in bbs.vertices():
        data.log.debug(f"{bbs.vp.name[bb]} has the following IR code:")
        data.log.debug(str(bbs.get_llvm_obj(bb)))
        dump.append([[bbs.vp.name[bb],
                      [os.path.relpath(os.path.realpath(x), start=script_dir)
                       for x in bbs.vp.files[bb]],
                      list(bbs.vp.lines[bb])]])

    data.log.info(json.dumps(sorted(dump, key=lambda x: x[0]), indent=2))
    fail_if(data.data != sorted(dump, key=lambda x: x[0]), "Data not equal")


if __name__ == '__main__':
    main()
