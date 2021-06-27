#!/usr/bin/env python3
import json
import io
import os.path

# Note: init_test must be imported first
from init_test import init_test, fail_if
from ara.graph import CFType

def main():
    """Test for correct instance detection."""
    config = {"steps": ["SIA"]}
    m_graph, data, log, _ = init_test(extra_config=config)
    instances = m_graph.instances
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    for instance in instances.vertices():
        i_dump = {}
        for name, prop in instances.vp.items():
            val = prop[instance]
            if name == 'file':
                val = os.path.relpath(val, start=script_dir)
            if name == 'llvm_soc':
                # wild pointer, skip this
                assert(val != 0)
                continue
            if name == 'soc':
                continue
            if prop.value_type() == 'python::object':
                # for now, just ignore
                # val = str(val)
                continue
            i_dump[name] = val
        dump.append(i_dump)

    # log.info(json.dumps(sorted(dump, key=lambda x: x['id']), indent=2))
    fail_if(data != sorted(dump, key=lambda x: x['id']), "Data not equal")


if __name__ == '__main__':
    main()
