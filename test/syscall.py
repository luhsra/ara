#!/usr/bin/env python3.6
import graph

from init_test import init_test


def main():
    """Test for correct syscall mapping."""

    m_graph, data, _ = init_test(['Syscall'])


if __name__ == '__main__':
    main()
