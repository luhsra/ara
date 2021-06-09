"""This file contains functions to translate common graphs to there JSON equivalent."""

import os.path

def json_callgraph(callgraph):
    """callgraph -> JSON Callgraph
    
    In this graph only the edges are contained.
    """
    c_edges = []
    for edge in callgraph.edges():
        c_edges.append([callgraph.vp.function_name[edge.source()],
                        callgraph.vp.function_name[edge.target()]])
    return sorted(c_edges)

def json_instance_graph(instances):
    """instances + interactions -> JSON Instance Graph"""
    dump = []

    script_dir = os.path.dirname(os.path.realpath(__file__))

    for instance in instances.vertices():
        i_dump = {}
        for name, prop in instances.vp.items():
            val = prop[instance]
            if name == 'file':
                if not val == 'N/A' and not val == '' and not val == ' ': 
                    val = os.path.relpath(val, start=script_dir)
            if name == 'llvm_soc':
                # wild pointer, skip this
                continue
            if name == 'soc':
                continue
            if prop.value_type() == 'python::object':
                # for now, just ignore
                # val = str(val)
                continue
            i_dump[name] = val
        i_dump["type"] = "instance"
        dump.append(i_dump)
    for edge in instances.edges():
        i_dump = {
            "source": instances.vp.id[edge.source()],
            "target": instances.vp.id[edge.target()],
        }
        for name, prop in instances.ep.items():
            val = prop[edge]
            i_dump[name] = val
        i_dump["type"] = "interaction"
        dump.append(i_dump)

    def sort_key(item):
        if item['type'] == "instance":
            return "0" + item['id']
        return "1"

    return sorted(dump, key=sort_key)