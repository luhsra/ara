#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import ABBType, CFType


def f_exp(cfg, ty):
    def actual_filter(abb):
        return cfg.vp.type[abb] == ty
    return actual_filter


def abbs(cfg, function):
    for edge in function.out_edges():
        if cfg.ep.type[edge] == CFType.f2a:
            yield edge.target()


def main():
    """Test for correct syscall mapping."""

    # We need to execute the Syscall step for all entry points.
    # Executing SIA will do this:
    config = {"steps": ["SIA"]}

    data = init_test(extra_config=config)
    cfg = data.graph.cfg
    functs = data.graph.functs
    stats = {}
    for function in functs.vertices():
        function = cfg.vertex(function)
        if not cfg.vp.implemented[function]:
            continue
        syscalls = sum(1 for _ in
                       (filter(f_exp(cfg, ABBType.syscall),
                               cfg.get_abbs(function))))
        calls = sum(1 for _ in
                    (filter(f_exp(cfg, ABBType.call),
                            cfg.get_abbs(function))))
        stats[cfg.vp.name[function]] = {"syscalls": syscalls, "calls": calls}
    # data.log.info(json.dumps(stats, indent=2))
    fail_if(data.data != stats, "Data not equal")


if __name__ == '__main__':
    main()
