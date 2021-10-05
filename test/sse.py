#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if


def main():
    """Test for correct SSE execution."""
    config = {"steps": ["LoadOIL",
                        {
                            "name": "Printer",
                            "dot": "cfg.dot",
                            "from_entry_point": False,
                            "graph_name": "CFG",
                            "subgraph": "abbs"
                        },
                        "SSE"]}
    inp = {"oilfile": lambda argv: argv[3]}
    m_graph, data, log, _ = init_test(extra_config=config, extra_input=inp)

    fail_if(data != {})


if __name__ == '__main__':
    main()
