#!/usr/bin/env python3
import json
import pyllco

# Note: init_test must be imported first
from init_test import init_test, fail_if
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
            # debug_print(cfg.vp.line[cg.ep.callsite[e]])
            # debug_print(cg.vp.function_name[e.source()])
            # debug_print(cg.vp.function_name[e.target()])
            t = (part["functs"][0] == cg.vp.function_name[e.source()])
            t = t and (part["functs"][1] == cg.vp.function_name[e.target()])
            t = t and (cfg.vp.line[cg.ep.callsite[e]] == part["line"])
            if t:
                # debug_print("found")
                cp.add_call_site(graph.callgraph, e)
                break
        else:
            raise RuntimeError(f"Callsite not found {cp_desc}")
    return cp


def main():
    """Test for correct value analysis recognition."""
    config = {"steps": ["Syscall"] + ValueAnalyzer.get_dependencies()}
    m_graph, data, log, _ = init_test(extra_config=config)
    global logger
    logger = log
    va = ValueAnalyzer(m_graph)

    cfg = m_graph.cfg

    syscalls = CFGView(cfg, vfilt=cfg.vp.type.fa == ABBType.syscall)

    for syscall in syscalls.vertices():
        name = syscalls.get_syscall_name(syscall)
        line = syscalls.vp.line[syscall]
        debug_print(20 * "-")
        debug_print(f"Handle syscall {name} (line {line}).")
        record = data[name][str(line)]
        for entry in record:
            callpath = create_callpath(m_graph, entry["callpath"])
            for idx, [hint, val] in enumerate(entry["args"]):
                debug_print(f"Searching arg {idx}, expected: {val}, cp: {callpath}")

                expected_error = None
                no_except = True
                if isinstance(val, str) and val.startswith('Error:'):
                    expected_error = val.split(' ')[1]

                try:
                    value, attr = va.get_argument_value(syscall, idx,
                                                        callpath=callpath,
                                                        hint=get_hint(hint))
                except Exception as e:
                    if type(e).__name__ == expected_error:
                        debug_print(f"Got expected error: {type(e).__name__}")
                        no_except = False
                    else:
                        raise e
                if no_except:
                    py_val = value_to_py(value, attr)
                    debug_print("Retrieved", py_val)
                    assert val == py_val
            if "is_creation" in entry:
                obj = entry["is_creation"]
                debug_print(f"Assign {obj['name']}.")
                if "arg" not in obj:
                    va.assign_system_object(syscall, obj["name"], callpath)
                else:
                    va.assign_system_object(syscall, obj["name"], callpath,
                                            obj["arg"])


if __name__ == '__main__':
    main()
