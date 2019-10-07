#!/usr/bin/env python3
import graph


def main():
    """Test for correct working of the graph library."""

    g = graph.create_graph(directed=True, with_subgraph=True)
    v1 = g.add_vertex()
    v2 = g.add_vertex()
    sg = g.create_subgraph()
    v3 = sg.add_vertex()

    assert v1.is_global()
    assert v2.is_global()
    assert not v3.is_global()
    assert hash(v1) != hash(v2) != hash(v3)
    assert v3 == sg.local_to_global(v3)


if __name__ == '__main__':
    main()
