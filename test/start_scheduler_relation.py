#!/usr/bin/env python3.6
import graph

from init_test import init_test, fail_with


def main():
    """Test for correct detection of the start scheduler relation.

    An abb can be before or after the scheduler call or it is uncertain."""
    m_graph, data, _ = init_test()

    abbs = [x for x in m_graph.get_type_vertices("ABB") if x is not None]

    for abb in abbs:
        relation = data[abb.get_name()]
        if (graph.start_scheduler_relation[relation] is not
                abb.get_start_scheduler_relation()):
            fail_with("Expected relation {relation} at {abb.get_name()}")


if __name__ == '__main__':
    main()
