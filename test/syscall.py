#!/usr/bin/env python3.6
import graph
import json

from graph import ABBType

from init_test import init_test, fail_if

def f_exp(ty):
    def actual_filter(abb):
        return abb.type == ty
    return actual_filter

def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(['Syscall'])
    abbs = m_graph.new_graph.abbs()
    stats = {}
    for function in abbs.functions():
        syscalls = sum(1 for _ in
                       (filter(f_exp(ABBType.syscall), function.vertices())))
        calls = sum(1 for _ in
                    (filter(f_exp(ABBType.call), function.vertices())))
        stats[function.name] = {"syscalls": syscalls, "calls": calls}
    fail_if(data != stats, "Data not equal")


if __name__ == '__main__':
    main()
