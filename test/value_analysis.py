#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
# SPDX-FileCopyrightText: 2021 Jan Neugebauer
# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import json

# Note: init_test must be imported first
from init_test import init_test
import pyllco
from ara.graph import ABBType, CFGView, SigType, CallPath
from ara.steps import get_native_component
ValueAnalyzer = get_native_component("ValueAnalyzer")


def value_to_py(value, attrs):
    if value is None:
        return "None"
    if isinstance(value, pyllco.ConstantPointerNull):
        return "null"
    if isinstance(value, pyllco.Function):
        return f"Function: {value.get_name()}"
    if isinstance(value, pyllco.GlobalVariable):
        return f"GlobalVariable: {value.get_name()}"
    if isinstance(value, pyllco.Constant):
        return value.get(attrs=attrs)
    if isinstance(value, pyllco.AllocaInst):
        return f"Alloca: {value.get_name()}"
    if isinstance(value, str):
        return value
    return str(type(value)) + ": " + str(value)


logger = None
def debug_print(*args):
    global logger
    logger.info(' '.join([str(x) for x in args]))
    pass


def get_hint(hint):
    return {"value": SigType.value,
            "symbol": SigType.symbol}[hint]


def create_callpath(graph, cp_desc):
    cp = CallPath()
    cg = graph.callgraph
    cfg = graph.cfg
    for part in cp_desc:
        call = None
        for e in cg.edges():
            # debug_print(part)
            # debug_print(cfg.vp.lines[cg.ep.callsite[e]])
            # debug_print(cg.vp.function_name[e.source()])
            # debug_print(cg.vp.function_name[e.target()])
            t = (part["functs"][0] == cg.vp.function_name[e.source()])
            t = t and (part["functs"][1] == cg.vp.function_name[e.target()])
            t = t and (cfg.vp.lines[cg.ep.callsite[e]][0] == part["line"])
            if t:
                # debug_print("found")
                cp.add_call_site(graph.callgraph, e)
                break
        else:
            raise RuntimeError(f"Callsite not found {cp_desc}")
    return cp

def perform_va_for_syscall(va, m_graph, syscalls, data, name, syscall):
    line = syscalls.vp.lines[syscall][0]
    debug_print(20 * "-")
    debug_print(f"Handle syscall {name} (line {line}).")
    record = data[name][str(line)]
    for entry in record:
        callpath = create_callpath(m_graph, entry["callpath"])
        for idx, [hint, val] in enumerate(entry["args"]):
            debug_print(f"Searching arg {idx}, expected: {val}, "
                        f"cp: {callpath}")

            expected_error = None
            no_except = True
            if isinstance(val, str) and val.startswith('Error:'):
                expected_error = val.split(' ')[1]

            try:
                result = va.get_argument_value(syscall, idx,
                                                callpath=callpath,
                                                hint=get_hint(hint))
            except Exception as e:
                if type(e).__name__ == expected_error:
                    debug_print(f"Got expected error: {type(e).__name__}")
                    no_except = False
                else:
                    raise e
            if no_except:
                py_val = value_to_py(result.value, result.attrs)
                debug_print("Retrieved", py_val)
                if result.offset:
                    num_offsets = [x.get_offset() for x in result.offset]
                    debug_print(f"With Offsets: "
                                f"{num_offsets} ({result.offset})")
                    assert val == [py_val, num_offsets]
                else:
                    assert val == py_val, f"Expected {val}, got {py_val}"
                if "is_creation" in entry:
                    obj = entry["is_creation"]
                    if "arg" in obj and obj['arg'] == idx:
                        debug_print(f"Assign {obj['name']} "
                                    f"to argument {idx}.")
                        va.assign_system_object(result.value,
                                                obj['name'],
                                                result.offset)
        if "is_creation" in entry:
            obj = entry["is_creation"]
            debug_print(f"Assign {obj['name']}.")
            if "arg" not in obj:
                store = va.get_return_value(syscall, callpath)
                debug_print(f"Got store: {store}")
                result = va.get_memory_value(store, callpath)
                debug_print(f"Got store: {store}, value: {result.value}, "
                            f"offset: {result.offset}")
                va.assign_system_object(result.value,
                                        obj["name"],
                                        result.offset)

def main():
    """Test for correct value analysis recognition."""

    # All creation syscalls that we are testing.
    creation_syscalls = set({"xQueueCreateMutex", "xTaskCreateStatic", "xTaskCreate"})

    config = {"steps": ["Syscall"] + ValueAnalyzer.get_dependencies()}
    data = init_test(extra_config=config)
    global logger
    logger = data.log
    va = ValueAnalyzer(data.graph)

    cfg = data.graph.cfg

    syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)

    # Search for syscalls in cfg and order them by type
    found_creation_syscalls = []
    found_interaction_syscalls = []
    for syscall in syscalls.vertices():
        name = cfg.get_syscall_name(syscall)
        if name in creation_syscalls:
            found_creation_syscalls.append((name, syscall))
        else:
            found_interaction_syscalls.append((name, syscall))

    # Creation syscalls must be handled before interaction syscalls.
    for syscall in found_creation_syscalls:
        perform_va_for_syscall(va, data.graph, syscalls, data.data,
                               syscall[0], syscall[1])

    for syscall in found_interaction_syscalls:
        perform_va_for_syscall(va, data.graph, syscalls, data.data,
                               syscall[0], syscall[1])


if __name__ == '__main__':
    main()
