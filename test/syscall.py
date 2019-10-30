#!/usr/bin/env python3.6
import graph
import json

from graph import ABBType, CFType

from init_test import init_test, fail_if


def f_exp(cfg, ty):
    def actual_filter(abb):
        return cfg.vp.tpye[abb] == ty
    return actual_filter


def abbs(cfg, function):
    for edge in function.out_edges():
        if cfg.ep.type[edge] == CFType.f2a:
            yield edge.target()


def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(['Syscall'])
    cfg = m_graph.cfg
    stats = {}
    for function in cfg.vertices():
        if cfg.vp.is_function[function]:
            return
        syscalls = sum(1 for _ in
                       (filter(f_exp(cfg, ABBType.syscall),
                               abbs(cfg, function))))
        calls = sum(1 for _ in
                    (filter(f_exp(cfg, ABBType.call), abbs(cfg, function))))
        stats[cfg.vp.name[function]] = {"syscalls": syscalls, "calls": calls}
    fail_if(data != stats, "Data not equal")


if __name__ == '__main__':
    main()
