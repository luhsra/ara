"""Multicore SSE analysis."""

import graph_tool
import pydot
import os
import html

from .option import Option, String
from .step import Step
from .cfg_traversal import Visitor, run_sse
from ara.os.os_base import OSState, CPU

# time counter for performance measures
c_debugging = 0  # in milliseconds

MAX_UPDATES = 2
MAX_STATE_UPDATES = 20
MIN_EMULATION_TIME = 200

sse_counter = 0


def debug_time(t_start):
    t_delta = datetime.now() - t_start
    global c_debugging
    c_debugging += t_delta.seconds * 1000 + t_delta.microseconds / 1000


_metastate_id = 0


def get_id():
    global _metastate_id
    _metastate_id += 1
    return _metastate_id


class MetaState:
    """State containing the summarized independent states for a single core
    execution"""

    def __init__(self, graph, instances, context_id):
        self.id = get_id()
        self.graph = graph
        self.instances = instances
        self.context_id = context_id
        self.state_graph = {}  # graph of Multistates for each cpu
        # key: cpu id, value: graph of Multistates
        self.sync_states = {}  # list of MultiStates for each cpu, which handle
        # a syscall that affects other cpus
        # key: cpu id, value: list of MultiStates
        self.entry_states = {}  # entry state for each cpu
        # key: cpu id, value: Multistate
        self.updated = 0  # amount of times this metastate has been updated (timings)


class MultiSSE(Step):
    """Run the MultiCore SSE."""

    entry_point = Option(name="entry_point", help="system entry point", ty=String())

    def get_single_dependencies(self):
        if self._graph.os is None:
            return ["SysFuncts"]
        deps = self._graph.os.get_special_steps()
        if self._graph.os.has_dynamic_instances():
            deps.append("SIA")
        return deps

    def _singlecore_state_as_dot(self, state_graph, state_vert, instances):
        attrs = {"fontsize": 14}
        size = 12
        label = f"State {state_vert}"
        cfg = self._graph.cfg
        graph_attrs = "<br/>".join(
            [
                f"<i>{k}</i>: {html.escape(str(v))}"
                for k, v in [
                    ("irq_on", bool(state_graph.vp.irq_on[state_vert])),
                    (
                        "instance",
                        instances.vp.label[instances.vertex(state_graph.vp.instance[state_vert])],
                    ),
                    ("abb", cfg.vp.name[state_graph.vp.abb[state_vert]]),
                    ("call_path", state_graph.vp.call_path[state_vert]),
                ]
            ]
        )
        graph_attrs = f"<font point-size='{size}'>{graph_attrs}</font>"
        attrs["label"] = f"<{label}<br/>{graph_attrs}>"
        return attrs

    def dump_metastate(self, metastate, extra=""):
        def _get_nname(cpu, id):
            return f"MS {id} ({cpu})"

        dot_graph = pydot.Dot(graph_type="digraph", label=f"Metastate {metastate.id}")

        for cpu, state_graph in metastate.state_graph.items():
            dot_cpu = pydot.Cluster(str(cpu), label=f"CPU {cpu}")
            dot_graph.add_subgraph(dot_cpu)
            for state_vert in state_graph.vertices():
                attrs = self._singlecore_state_as_dot(
                    state_graph, state_vert, metastate.instances
                )
                dot_state = pydot.Node(_get_nname(cpu, state_vert), **attrs)
                dot_cpu.add_node(dot_state)
            for edge in state_graph.edges():
                dot_graph.add_edge(
                    pydot.Edge(
                        _get_nname(cpu, edge.source()),
                        _get_nname(cpu, edge.target()),
                        color="black",
                    )
                )

        dot_file = self.dump_prefix.get() + f"metastate.{metastate.id}.{extra}.dot"
        dot_path = os.path.abspath(dot_file)
        os.makedirs(os.path.dirname(dot_path), exist_ok=True)
        dot_graph.write(dot_path)

        self._log.info(f"Write metastate {metastate.id} to {dot_path}.")

    def dump_sstg(self, sstg):
        pass

    def _gen_sctg(self):
        """Generate the initial single core transition graph."""
        graph = graph_tool.Graph()
        graph.vertex_properties["irq_on"] = graph.new_vp("bool")
        graph.vertex_properties["instance"] = graph.new_vp("int64_t")
        graph.vertex_properties["abb"] = graph.new_vp("int64_t")
        graph.vertex_properties["call_path"] = graph.new_vp("object")

        graph.edge_properties["is_timed_event"] = graph.new_ep("bool")
        graph.edge_properties["is_isr"] = graph.new_ep("bool")
        return graph

    def _run_sse(self, metastate):
        """Run the single core SSE for the given metastate on each cpu."""
        for cpu_id, graph in metastate.state_graph.items():
            self._log.debug(f"Run SSE on cpu {cpu_id}")
            global sse_counter
            sse_counter += 1

            entry = graph.get_vertices()[0]

            cpu = CPU(
                id=cpu_id,
                irq_on=graph.vp.irq_on[entry],
                control_instance=graph.vp.instance[entry],
                abb=graph.vp.abb[entry],
                call_path=graph.vp.call_path[entry],
                analysis_context=None,
            )

            init_state = OSState(cpus=[cpu], instances=metastate.instances)

            for c_instance in init_state.instances.get_controls().vertices():
                inst = init_state.instances.vp.obj[c_instance]
                assert inst.context[metastate.context_id] is not None, f"{inst} has invalid context for multisse"
                inst.context[init_state.id] = inst.context[metastate.context_id]

            id_map = {init_state.id: entry}

            class SSEVisitor(Visitor):
                PREVENT_MULTIPLE_VISITS = True

                @staticmethod
                def get_initial_state():
                    return init_state

                @staticmethod
                def init_execution(_):
                    return

                @staticmethod
                def is_bad_call_target(_):
                    return False

                @staticmethod
                def schedule(new_states):
                    return self._graph.os.schedule(new_states, [cpu_id])

                @staticmethod
                def add_state(new_state):
                    s = graph.add_vertex()
                    graph.vp.irq_on[s] = new_state.cpus[0].irq_on
                    graph.vp.instance[s] = new_state.cpus[0].control_instance
                    graph.vp.abb[s] = new_state.cpus[0].abb
                    graph.vp.call_path[s] = new_state.cpus[0].call_path
                    id_map[new_state.id] = s

                @staticmethod
                def add_transition(source, target):
                    graph.add_edge(id_map[source.id], id_map[target.id])

                @staticmethod
                def next_step(counter):
                    self.dump_metastate(metastate, extra=str(counter))

            run_sse(
                self._graph,
                self._graph.os,
                visitor=SSEVisitor(),
                logger=self._log,
            )

            if self.dump.get():
                self.dump_metastate(metastate, extra="final")

            # v_start = graph.get_vertices()[0]
            # stack = [v_start]
            # found_list = []
            # isr_is_not_done = True

            # while isr_is_not_done:
            #     isr_states = []
            #     isr_vertices = []
            #     while stack:
            #         vertex = stack.pop(0)
            #         state = graph.vp.state[vertex]
            #         found_list.append(vertex)

            #         # add state to isr list if interrupts enabled flag is true
            #         abb = state.get_running_abb()
            #         if state.interrupts_enabled.get_value() and (abb is None or state.cfg.vp.type[abb] != ABBType.syscall) and not state.interrupt_handled:
            #             isr_states.append(state)
            #             isr_vertices.append(vertex)
            #             state.interrupt_handled = True

            #         # execute popped state
            #         new_states = self.execute_state(vertex, metastate.sync_states[cpu], graph)

            #         # add existing neighbors to stack
            #         for v in graph.vertex(vertex).out_neighbors():
            #             neighbor_state = graph.vp.state[v]
            #             # if neighbor_state.updated < MAX_STATE_UPDATES:
            #             #     neighbor_state.updated += 1
            #             if len(neighbor_state.global_times_merged) > 0 and neighbor_state.global_times_merged[-1][1] < MIN_EMULATION_TIME and len(neighbor_state.global_times) > 0:
            #                 if v not in stack:
            #                     stack.append(v)

            #         for new_state in new_states:
            #             found = False

            #             # check for duplicate states
            #             for v in graph.vertices():
            #                 existing_state = graph.vp.state[v]

            #                 # add edge to existing state if new state is equal
            #                 if new_state == existing_state:
            #                     found = True

            #                     # add edge to graph
            #                     if v not in graph.vertex(vertex).out_neighbors():
            #                         e = graph.add_edge(vertex, v)

            #                         # edge coloring after timed events, e.g. Alarms
            #                         if new_state.from_event:
            #                             graph.ep.is_timed_event[e] = True
            #                         else:
            #                             graph.ep.is_timed_event[e] = False

            #                         # edge coloring after isr
            #                         if new_state.from_isr:
            #                             graph.ep.is_isr[e] = True
            #                         else:
            #                             graph.ep.is_isr[e] = False

            #                     # copy all global times to existing state
            #                     for intervall in new_state.global_times:
            #                         existing_state.global_times.append(intervall)

            #                     # if new_state.from_event:
            #                     #     # copy passed event times to existing state
            #                     #     for event_time in new_state.passed_events:
            #                     #         if event_time not in existing_state.passed_events:
            #                     #             existing_state.passed_events.append(event_time)
            #                     #     existing_state.passed_events.sort()

            #                     # if existing_state.updated < MAX_STATE_UPDATES:
            #                     #     existing_state.updated += 1
            #                     if len(existing_state.global_times_merged) > 0 and existing_state.global_times_merged[-1][1] < MIN_EMULATION_TIME:
            #                         if v not in stack:
            #                             stack.append(v)
            #                     break

            #             # add new state to graph and append it to the stack
            #             if not found:
            #                 new_vertex = graph.add_vertex()
            #                 graph.vp.state[new_vertex] = new_state
            #                 e = graph.add_edge(vertex, new_vertex)

            #                 # edge coloring after timed events, e.g. Alarms
            #                 if new_state.from_event:
            #                     graph.ep.is_timed_event[e] = True
            #                     new_state.from_event = False
            #                 else:
            #                     graph.ep.is_timed_event[e] = False

            #                 # edge coloring after isr
            #                 if new_state.from_isr:
            #                     graph.ep.is_isr[e] = True
            #                     new_state.from_isr = False
            #                 else:
            #                     graph.ep.is_isr[e] = False

            #                 if new_vertex not in stack:
            #                     stack.append(new_vertex)

            #     # compress states for isr routines
            #     if len(isr_states) > 0:
            #         isr_starting_states = []

            #         isr_states_left = []
            #         isr_vertices_left = []

            #         # handle isr for each picked state
            #         for i, isr_state in enumerate(isr_states):
            #             ret = self._graph.os.handle_isr(isr_state)
            #             isr_starting_states.extend(ret)

            #             if len(ret) > 0:
            #                 isr_states_left.append(isr_state)
            #                 isr_vertices_left.append(isr_vertices[i])

            #         if len(isr_starting_states) > 0:
            #             compressed_state = self.compress_states(isr_starting_states)
            #             print(f"isr compressed state: {compressed_state}")

            #             # combine all global times merged into the compressed state
            #             for isr_state in isr_states_left:
            #                 for intervall in isr_state.global_times_merged:
            #                     compressed_state.global_times.append(intervall)

            #             new_states = AUTOSAR.decompress_state(compressed_state)

            #             for state in new_states:
            #                 new_vertex = graph.add_vertex()
            #                 graph.vp.state[new_vertex] = state
            #                 stack.append(new_vertex)

            #                 for start_vertex in isr_vertices_left:
            #                     e = graph.add_edge(start_vertex, new_vertex)
            #                     graph.ep.is_isr[e] = True
            #                     graph.ep.is_timed_event[e] = False
            #     else:
            #         isr_is_not_done = False

    def _get_initial_state(self):
        os_state = self._graph.os.get_initial_state(
            self._graph.cfg, self._graph.instances
        )

        # building initial metastate
        metastate = MetaState(graph=self._graph, instances=os_state.instances,
                              context_id=os_state.id)

        for cpu in os_state.cpus:
            print("CPU:", cpu)
            # graph
            metastate.state_graph[cpu.id] = self._gen_sctg()
            metagraph = metastate.state_graph[cpu.id]

            # initial vertex
            state_v = metagraph.add_vertex()

            metagraph.vp.irq_on[state_v] = cpu.irq_on
            metagraph.vp.abb[state_v] = cpu.abb
            metagraph.vp.instance[state_v] = cpu.control_instance
            metagraph.vp.call_path[state_v] = cpu.call_path

        self.dump_metastate(metastate, extra="init")

        # # go through all instances and build all initial MultiStates accordingly
        # for v in instances.vertices():
        #     task = instances.vp.obj[v]
        #     state = None
        #     if isinstance(task, AUTOSAR_Task):
        #         if task.cpu_id not in found_cpus:
        #             # create new MultiState
        #             state = MultiState(cfg=cfg,instances=instances,
        #                                callgraph=callgraph, cpu=task.cpu_id,
        #                                keygen=keygen)
        #             found_cpus[task.cpu_id] = state

        #             # add new state to Metastate
        #             metastate.state_graph[state.cpu] = graph_tool.Graph()
        #             graph = metastate.state_graph[state.cpu]
        #             graph.vertex_properties["state"] = graph.new_vp("object")
        #             graph.edge_properties["is_timed_event"] = graph.new_ep("bool")
        #             graph.edge_properties["is_isr"] = graph.new_ep("bool")
        #             vertex = graph.add_vertex()
        #             graph.vp.state[vertex] = state

        #             # add empty list to sync_states in Metastate
        #             metastate.sync_states[state.cpu] = []
        #         else:
        #             state = found_cpus[task.cpu_id]

        #         # set entry abb for each task
        #         entry_abb = cfg.get_entry_abb(task.function)
        #         state.entry_abbs[task.name] = entry_abb

        #         # setup abbs dict with entry abb for each task
        #         state.abbs[task.name] = OptionType(state.key, entry_abb)

        #         # set list of activated tasks
        #         if task.autostart:
        #             state.activated_tasks.append_item(task)

        # # setup all ISRs
        # for v in instances.vertices():
        #     isr = instances.vp.obj[v]
        #     if isinstance(isr, ISR):
        #         state = found_cpus[isr.cpu_id]

        #         # set entry abb for each ISR
        #         entry_abb = cfg.get_entry_abb(isr.function)
        #         state.entry_abbs[isr.name] = entry_abb

        #         # setup abbs dict with entry abb for each ISR
        #         state.abbs[isr.name] = OptionType(state.key, entry_abb)

        # # build starting times for each multistate
        # for cpu, graph in metastate.state_graph.items():
        #     v = graph.get_vertices()[0]
        #     state = graph.vp.state[v]
        #     abb = state.get_running_abb()
        #     context = None
        #     max_time = Timings.get_max_time(state.cfg, abb, context)
        #     state.local_times = [(0, max_time)]
        #     state.global_times = [(0, max_time)]
        #     # state.root_global_times = [(0, 0)]

        # run single core sse for each cpu
        self._run_sse(metastate)

        return metastate

    def _new_vertex(self, sstg, state):
        vertex = sstg.add_vertex()
        sstg.vp.state[vertex] = state
        return vertex

    def run(self):
        entry_label = self.entry_point.get()
        if not entry_label:
            self._fail("Entry point must be given.")
        self._log.info(f"Analyzing entry point: '{entry_label}'")

        sstg = graph_tool.Graph()
        sstg.vertex_properties["state"] = sstg.new_vp("object")
        sstg.edge_properties["syscall"] = sstg.new_ep("object")
        sstg.edge_properties["state_list"] = sstg.new_ep("object")

        state_vertex = self._new_vertex(sstg, self._get_initial_state())

        stack = [state_vertex]

        return

        counter = 0
        while stack:
            self._log.debug(
                f"Round {counter:3d}, "
                f"Stack with {len(stack)} state(s): "
                f"{[sstg.vp.state[v] for v in stack]}"
            )
            state_vertex = stack.pop(0)
            for n in self._meta_transition(state_vertex, sstg):
                new_state = self.new_vertex(sstg, n)
                sstg.add_edge(state_vertex, new_state)
                stack.append(new_state)

            counter += 1

        self._log.info(f"Analysis needed {counter} iterations.")

        self._graph.sstg = sstg
