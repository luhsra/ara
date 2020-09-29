#!/usr/bin/env python3
import json
import pyllco

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import ABBType, CFGView

def value_to_str(value):
    if value is None:
        return "None"
    if isinstance(value, pyllco.ConstantPointerNull):
        return "null"
    if isinstance(value, pyllco.Function):
        return f"Function: {value.get_name()}"
    if isinstance(value, pyllco.GlobalVariable):
        return f"GlobalVariable: {value.get_name()}"
    if isinstance(value, pyllco.Constant):
        return value.get()
    if isinstance(value, pyllco.AllocaInst):
        return f"Alloca: {value.get_name()}"
    return str(type(value)) + ": " + str(value)


def debug_print(*args):
    # print(*args)
    pass


def main():
    """Test for correct value analysis recognition."""
    config = {"steps": ["ValueAnalysis"]}
    m_graph, data, _ = init_test(extra_config=config)
    cfg = m_graph.cfg
    syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)

    values = {}

    for syscall in syscalls.vertices():
        debug_print("Syscall:", syscalls.get_syscall_name(syscall))
        args = syscalls.vp.arguments[syscall]

        val_per_args = []

        for argument in args:
            val_per_arg = []
            for call_path, value in argument.items():
                val_per_arg.append(
                    [call_path.print(functions=True), value_to_str(value)]
                )
            debug_print("Argument:", val_per_arg)
            val_per_args.append(val_per_arg)
        return_value = args.get_return_value()
        tracked_ret_value = "no return"
        if return_value is not None:
            assert(len(return_value) == 1)
            tracked_ret_value = value_to_str(return_value.get_value(raw=True))
        debug_print("RETVAL:", tracked_ret_value)

        values[syscalls.get_syscall_name(syscall)] = [tracked_ret_value, val_per_args]

    # import json
    # print(json.dumps(values))
    fail_if(data != values, "Data not equal")


if __name__ == '__main__':
    main()
