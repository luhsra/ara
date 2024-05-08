# SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Container for FindPointerLoops."""
from .step import Step
from .option import Option, Integer

import subprocess

from collections import defaultdict
from pathlib import Path
from graph_tool.topology import all_circuits


class FindPointerLoops(Step):
    """Show loops in the callgraph.

    Normally, callgraphs for RTS should contain no recursion and, thus, no
    loop. Due to overapproximations with function pointers there might be
     unwanted loops. This step finds and prints these loops.
     """
    dummy_option = Option(name="dummy_option",
                          help="An option to demonstrate options.",
                          ty=Integer())

    def get_single_dependencies(self):
        return ["CallGraph"]

    def run(self):
        callgraph = self._graph.callgraph

        for vertex in callgraph.vertices():
            for out in vertex.out_edges():
                self._log.warn("%s connected via %s to %s",
                               callgraph.vp.function_name[vertex],
                               callgraph.ep.callsite_name[out],
                               callgraph.vp.function_name[out.target()])

        # syscall_graph = callgraph.get_syscalls()
        # cfg = self._graph.cfg

        # syscall_nodes = []
        # entry = None
        # for vertex in syscall_graph.vertices():
        #     if callgraph.vp.function_name[vertex] == '__ara_fake_entry':
        #         entry = vertex
        #     if cfg.vp.sysfunc[cfg.vertex(callgraph.vp.function[vertex])]:
        #         syscall_nodes.append(vertex)

        # assert entry != None
        # for vertex in syscall_nodes:
        #     for path in [shortest_path(syscall_graph, entry, vertex)[0]]:
        #         named_path = '-'.join([callgraph.vp.function_name[x] for x in path])
        #         self._log.warn("PATH: %s", named_path)

        # for vertex in callgraph.vertices():
        #     path, _ = shortest_path(callgraph, vertex, vertex)
        #     if len(path) > 0:
        #         named_path = '-'.join([callgraph.vp.function_name[x] for x in path])
        #         self._log.warn("PATH: %s", named_path)
        cfg = self._graph.cfg

        cycle_hotness = defaultdict(list)
        for idx, circle in enumerate(all_circuits(callgraph)):
            if idx > 20000:
                break
            for node in circle:
                cycle_hotness[callgraph.vp.function_name[node]].append(circle)

        for idx, (func, circles) in enumerate(sorted(cycle_hotness.items(), key=lambda x: len(x[1]))):
            if idx > 3:
                self._fail("bad")

            def unwrap(x):
                return subprocess.check_output(['c++filt', x]).decode('UTF-8').strip()

            self._log.warn("Hotness %d, Function %s", idx, unwrap(func))
            circle = circles[0]

            warning = "CIRCLE PATH:\n-----------------------\n\n"
            self._log.warn(repr(list(circle)))
            for src, dst in zip(list(circle), list(circle)[1:] + [None]):
                src_lbl = unwrap(callgraph.vp.function_name[src])
                if dst is None:
                    continue
                for edge in callgraph.edge(src, dst, all_edges=True):
                    cs = callgraph.ep.callsite[edge]
                    files = cfg.vp.files[cs]
                    lines = cfg.vp.lines[cs]
                    locations = set()
                    for file, line in zip(files, lines):
                        if line == 0:
                            continue
                        locations.add((file, line))
                    if not callgraph.ep.indirect[edge]:
                        loc_compressed = defaultdict(set)
                        for file, line in locations:
                            loc_compressed[Path(file)].add(str(line))
                        loc_compressed = {file.name: ':'.join(lines) for file, lines in loc_compressed.items()}
                        src_lbl += " (" + ' '.join([f"{file}:{lines}" for file, lines in loc_compressed.items()]) + ')\n'
                        continue
                    src_lbl += '\n'
                    for file, line in locations:
                        fl = f'    {file}:{line}\n'
                        ct = ''
                        with open(file) as f:
                            ct = '    ' + f.read().splitlines()[line - 1] + '\n'
                        src_lbl += fl + ct
                        others = set()
                        for other_edge in callgraph.vertex(src).out_edges():
                            if callgraph.ep.callsite[other_edge] == cs:
                                others.add(callgraph.vp.function_name[other_edge.target()])
                        if others:
                            src_lbl += '    Other callsites\n' + ''.join([f'        {unwrap(x)}\n' for x in others])
                warning += src_lbl
            self._log.warn(warning)
