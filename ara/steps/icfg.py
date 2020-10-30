"""Container for Syscall."""
from ara.graph import ABBType, CFType, Graph, CFGView
from .step import Step
from .option import Option, String

from collections import deque
from enum import IntEnum


class ICFG(Step):
    """Map interprocedural edges.

    It maps only system relevant functions.
    """
    entry_point = Option(name="entry_point",
                         help="system entry point",
                         ty=String())

    class _ET(IntEnum):
        IN = 0
        OUT = 1
        STD = 2

    def get_single_dependencies(self):
        return [{"name": "CallGraph", "entry_point": self.entry_point.get()},
                "SystemRelevantFunctions"]

    def run(self):
        entry_label = self.entry_point.get()
        entry_func = self._graph.cfg.get_function_by_name(entry_label)

        cfg = self._graph.cfg
        lcfg = CFGView(cfg, efilt=self._graph.cfg.ep.type.fa == CFType.lcf)
        icfg = CFGView(cfg, efilt=self._graph.cfg.ep.type.fa == CFType.icf)
        cg = self._graph.callgraph

        funcs_queue = deque([entry_func])
        funcs_done = set()

        link_counter = 0
        callsite_counter = 0

        to_s = {
            ICFG._ET.IN: "ingoing",
            ICFG._ET.OUT: "outgoing",
        }

        while funcs_queue:
            cur_func = funcs_queue.popleft()
            if cur_func in funcs_done:
                continue
            funcs_done.add(cur_func)

            self._log.debug(f"Analyzing function {cfg.vp.name[cur_func]}.")

            to_be_linked = []

            for abb in cfg.get_abbs(cur_func):
                if (icfg.vertex(abb).out_degree() > 0):
                    # function already handled in a previous ICFG run
                    continue
                # find other functions
                linked = False
                if cfg.vp.type[abb] in [ABBType.syscall, ABBType.call]:
                    cg_vtx = cg.vertex(cfg.vp.call_graph_link[cur_func])
                    callsite_counter += 1
                    for callsite in cg_vtx.out_edges():
                        if cg.ep.callsite[callsite] == abb:
                            cg_callee = callsite.target()
                            if cg.vp.syscall_category_every[cg_callee]:
                                callee = cg.vp.function[callsite.target()]
                                self._log.debug("Found system relevant call "
                                                f"to {cfg.vp.name[callee]}.")
                                funcs_queue.append(callee)
                                entry = cfg.get_entry_abb(cfg.vertex(callee))
                                to_be_linked.append((ICFG._ET.IN, abb, entry))
                                link_counter += 1
                                linked = True
                                assert lcfg.vertex(abb).out_degree() == 1
                                n_abb = next(lcfg.vertex(abb).out_neighbors())
                                exit_abb = cfg.get_exit_abb(cfg.vertex(callee))
                                if exit_abb:
                                    to_be_linked.append(
                                        (ICFG._ET.OUT, exit_abb, n_abb)
                                    )
                    if not linked:
                        cfg.vp.type[abb] = ABBType.computation
                if not linked:
                    # link local cfg
                    for n_abb in lcfg.vertex(abb).out_neighbors():
                        to_be_linked.append((ICFG._ET.STD, abb, n_abb))

            # link abbs
            for ty, src, target in to_be_linked:
                if ty in [ICFG._ET.IN, ICFG._ET.OUT]:
                    s = cfg.vp.name[src]
                    t = cfg.vp.name[target]
                    self._log.debug(f"Add {to_s[ty]} edge from {s} to {t}.")
                edge = cfg.add_edge(src, target)
                cfg.ep.type[edge] = CFType.icf

        self._log.info(
            f"Link {callsite_counter} callsites with {link_counter} functions."
        )

        if self.dump.get():
            dot_file = f'{self.dump_prefix.get()}{entry_label}.dot'
            name = f"ICFG (Function: {entry_label})"
            self._step_manager.chain_step({"name": "Printer",
                                           "dot": dot_file,
                                           "graph_name": name,
                                           "entry_point": entry_label,
                                           "from_entry_point": True,
                                           "subgraph": 'abbs'})
