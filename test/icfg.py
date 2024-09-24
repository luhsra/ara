#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Note: init_test must be imported first
from init_test import init_test, fail_if_json_not_equal
from ara.graph import CFType


def main():
    """Test for correct icfg mapping."""
    config = {"steps": ["ICFG", {"name": "ICFG",
                                 "entry_point": "_Z14other_functioni"},
                        "ICFG", {"name": "ICFG",
                                 "entry_point": "main"},
                        "DumpCallgraph",
                        "DumpCFG"]}
    data = init_test(extra_config=config)
    cfg = data.graph.cfg
    icf_edges = []
    for edge in filter(lambda x: cfg.ep.type[x] == CFType.icf, cfg.edges()):
        src = cfg.vp.name[edge.source()]
        dst = cfg.vp.name[edge.target()]
        icf_edges.append([src, dst])
    # with open(data.data_file, "w") as f:
    #     import json
    #     json.dump(sorted(icf_edges), f, indent=2, sort_keys=True)
    fail_if_json_not_equal(data.data, sorted(icf_edges))


if __name__ == '__main__':
    main()
