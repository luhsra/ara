#!/usr/bin/env python3

# Note: init_test must be imported first
from init_test import init_test, fail_if

import json
import sys
import logging


def _dump_trace(trace):
    ns = ',\n'.join([f"    {json.dumps(x)}" for x in trace["vertices"]])
    es = ',\n'.join([f"    {json.dumps(x)}" for x in trace["edges"]])
    print(f'{{\n  "vertices": [\n{ns}\n  ],\n  "edges": [\n{es}\n  ]\n}}',
          file=sys.stderr)


def _get_trace(sstg, v):
    state = sstg.vp.state[v]
    cpu = state.cpus[0]
    if cpu.control_instance:
        syscall = state.cfg.get_syscall_name(state.cfg.vertex(cpu.abb))
        instance = state.instances.vp.label[state.instances.vertex(cpu.control_instance)]
        if syscall != "":
            return (syscall, instance, str(cpu.call_path))
    else:
        return ("Idle",)
    start = sstg.vertex(sstg.gp.start)
    if v == start:
        return ("Start",)
    assert(False)


def _to_tuple(t):
    return tuple(map(_to_tuple, t)) if isinstance(t, (list, tuple)) else t


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
                        "LockElision"]}
    inp = {"oilfile": lambda argv: argv[3]}
    data = init_test(extra_config=config, extra_input=inp)

    locks = data.graph.step_data["LockElision"]
    t_data = data.data['no_timing']

    if data.log.level <= logging.INFO:
        data.log.warning(json.dumps(locks))
    fail_if(t_data['spin_states'] != locks['spin_states'])
    if 'DEADLOCK' in t_data:
        fail_if(t_data['DEADLOCK'] != locks['DEADLOCK'])


if __name__ == '__main__':
    main()
