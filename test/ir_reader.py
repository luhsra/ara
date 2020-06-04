#!/usr/bin/env python3.6
from init_test import init_test


def main():
    """Test for correct creation of the LLVM module from multiple IR files."""

    m_graph, data, _ = init_test(['IRReader'])


if __name__ == '__main__':
    main()
