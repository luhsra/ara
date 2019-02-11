#!/usr/bin/env python3.6

from init_test import init_test


def main():

    """Test for topological sort."""
    graph, data, _ = init_test()
    
    print(data)

    functions = graph.get_type_vertices("Function")

    for func in functions:
        func_order = [x.get_name() for x in func.get_atomic_basic_blocks()]
        assert len(func_order) == len(data[func.get_name()])
        for should, have in zip(func_order, data[func.get_name()]):
            assert should == have


if __name__ == '__main__':
    main()
