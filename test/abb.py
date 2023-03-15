#!/usr/bin/env python3.6

# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import ABBType, CFType, edge_types
from hashlib import sha1


def main():
    """Test for correct icfg mapping."""
    config = {"steps": [{"name": "CreateABBs", "entry_point": "_Z6vTask1Pv"},
                        {"name": "CreateABBs", "entry_point": "_Z6vTask2Pv"},
                        {"name": "CreateABBs", "entry_point": "main"},
                        'DumpCFG']}
    data = init_test(extra_config=config)
    abbs = data.graph.abbs
    cfg = data.graph.cfg
    out_v = []
    out_e = []
    mapping = {}
    for abb in abbs.vertices():
        bbs = cfg.get_bbs(abb)
        bout = []
        for bb in bbs:
            bout.append({"name": cfg.vp.name[bb],
                         "is_exit": cfg.vp.is_exit[bb],
                         "part_of_loop": cfg.vp.part_of_loop[bb],
                         "implemented": cfg.vp.implemented[bb],
                         "type": str(ABBType(cfg.vp.type[bb])),
                         "lines": list(cfg.vp.lines[bb])})

        lout = {"bbs": bout,
                "is_exit": cfg.vp.is_exit[abb],
                "part_of_loop": cfg.vp.part_of_loop[abb],
                "implemented": cfg.vp.implemented[abb],
                "type": str(ABBType(cfg.vp.type[bb])),
                "id": sha1(json.dumps(bout).encode("UTF-8")).hexdigest()[:8]}
        mapping[abb] = lout["id"]

        out_v.append(lout)

    cf = edge_types(abbs, abbs.ep.type, CFType.lcf, CFType.icf)
    for edge in cf.edges():
        eout = {"source": mapping[edge.source()],
                "target": mapping[edge.target()],
                "type": str(CFType(cfg.ep.type[edge]))}
        out_e.append(eout)

    out = {"vertices": sorted(out_v, key=lambda v: v['id']),
           "edges": sorted(out_e, key=lambda e: (e['source'], e['target']))}

    # with open(data.data_file, "w") as f:
    #     json.dump(out, f, indent=2)
    fail_if(data.data != out, "Data not equal")


if __name__ == '__main__':
    main()
