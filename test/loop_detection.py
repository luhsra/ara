#!/usr/bin/env python3.6
from init_test import init_test, fail_with


def main():

    """Test for false or not detected loops."""
    graph, data, _ = init_test()

    abbs = graph.get_type_vertices("ABB")
    for abb in abbs:
        if (abb is not None and abb.get_name() in data and
                not abb.get_loop_information()):
            fail_with("abb has no loop information: ", abb.get_name())


if __name__ == '__main__':
    main()
