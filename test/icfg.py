#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import CFType


def main():
    """Test for correct icfg mapping."""
    config = {"steps": ["ICFG", {"name": "ICFG",
                                 "entry_point": "_Z14other_functioni"},
                        "ICFG", {"name": "ICFG",
                                 "entry_point": "main"}]}
    data = init_test(extra_config=config)
    cfg = data.graph.cfg
    icf_edges = []
    for edge in filter(lambda x: cfg.ep.type[x] == CFType.icf, cfg.edges()):
        icf_edges.append([hash(edge.source()),
                          hash(edge.target())])
    # data.log.info(str(sorted(icf_edges)))
    fail_if(data.data != sorted(icf_edges), "Data not equal")


if __name__ == '__main__':
    main()
