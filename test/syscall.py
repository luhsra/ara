#!/usr/bin/env python3.6
import graph

from graph import ABBType, abb_filter_by

from init_test import init_test


def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(['Syscall'])
    abbs = m_graph.newgraph.abbs()
    stats = {}
    #for function in abbs.functions():
    #    syscalls = sum(1 for _ in (abb_filter_by(function, ABBType.syscall)))
    #    calls = sum(1 for _ in (abb_filter_by(function, ABBType.call)))
    #    stats[function.name] = (syscalls, calls)
    #assert_equal(test_data, stats)


if __name__ == '__main__':
    main()
