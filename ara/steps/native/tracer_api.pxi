# cython: language_level=3
# vim: set et ts=4 sw=4:

from ara.visualization.trace.tracer_api.tracer import GraphNode, GraphPath

cdef public object py_tracer_get_entity(object tracer, const string& name):
    return tracer.get_entity(name.decode('UTF-8'))

cdef public void py_entity_on_node(object tracer, object entity, object node, int graph_type) except *:
    g_node = GraphNode(node, graph_type)
    tracer.entity_on_node(entity, g_node)

cdef public void py_entity_is_looking_at(object tracer, object entity, object path, int graph_type) except *:
    assert path is not None, "path is not containing any edges"
    g_path = GraphPath(path, graph_type)
    tracer.entity_is_looking_at(entity, g_path)

cdef public void py_go_to_node(object tracer, object entity, object path, int graph_type, bint forward) except *:
    assert path is not None, "path is not containing any edges"
    g_path = GraphPath(path, graph_type)
    tracer.go_to_node(entity, g_path, forward)


cdef public object py_copy_object(object obj):
    return obj.copy()

cdef public object py_get_vertex_by_id(object tracer, unsigned long v_id, int graph_type):
    return tracer.get_vertex_by_id(v_id, graph_type)

cdef public object py_add_edge_to_path(object tracer, object edge_list, unsigned long source, unsigned long target, int graph_type):
    if edge_list is None:
        edge_list = []
    edge_list.append(tracer.get_edge_by_nodes(source, target, graph_type))
    return edge_list
