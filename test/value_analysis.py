#!/usr/bin/env python3.6
import json

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import ABBType, CFGView


def main():
    """Test for correct value analysis recognition."""
    config = {"steps": ["ValueAnalysis", {"name": "ValueAnalysis",
                                          "entry_point": "main"}]}
    m_graph, data, _ = init_test(extra_config=config)
    cfg = m_graph.cfg
    syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)

    values = {}

    for syscall in syscalls.vertices():
        args = syscalls.vp.arguments[syscall]

        val_per_args = []

        for argument in args:
            val_per_arg = []
            for call_path, value in argument.items():
                val_per_arg.append(
                    [call_path.print(functions=True), value.get()]
                )
            val_per_args.append(val_per_arg)

        values[syscalls.get_syscall_name(syscall)] = val_per_args

    fail_if(data != values, "Data not equal")


if __name__ == '__main__':
    main()
