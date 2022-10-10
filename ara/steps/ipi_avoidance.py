"""Container for IPIAvoidance."""
from ara.graph import MSTType, single_check
from .step import Step

import timeit


class IPIAvoidance(Step):
    """Detect unnecessary IPIs for ActivateTask calls.

    If an ActivateTask should activate a Task on another core but this core is
    running a higher priority task on all possible synchronisation points, the
    operating system does not have to trigger an IPI but can set a flag only.
    """
    def get_single_dependencies(self):
        return ["MultiSSE"]

    def _is_ipi_needed(self, state):
        mstg = self._graph.mstg
        st2sy = mstg.edge_type(MSTType.st2sy)
        en2ex = mstg.edge_type(MSTType.en2ex)
        handled = set()

        ipi_needed = False
        for sync in st2sy.vertex(state).out_neighbors():
            handled.add(sync)
            exit_sync = single_check(en2ex.vertex(sync).out_neighbors())

            cpu_id = None
            in_other = None
            for e in st2sy.vertex(sync).in_edges():
                in_other = e.source()
                if in_other != state:
                    cpu_id = st2sy.ep.cpu_id[e]
                    break

            out_other = single_check([
                e.target() for e in st2sy.vertex(exit_sync).out_edges()
                if st2sy.ep.cpu_id[e] == cpu_id
            ])

            in_task = mstg.vp.state[in_other].cpus.one().control_instance
            out_task = mstg.vp.state[out_other].cpus.one().control_instance

            if in_task != out_task:
                ipi_needed = True

        return ipi_needed, handled

    def run(self):
        mstg = self._graph.mstg
        st2sy = mstg.edge_type(MSTType.st2sy)

        if self._graph.os.get_name() != "AUTOSAR":
            self._fail("Currently this is only implemented for AUTOSAR")

        handled_sync = set()

        out = []

        for sync in mstg.get_sync_points().vertices():
            if sync in handled_sync:
                continue

            if st2sy.vertex(sync).in_degree() == 2:
                for state in st2sy.vertex(sync).in_neighbors():
                    syscall_name = mstg.get_syscall_name(state)
                    if syscall_name == "AUTOSAR_ActivateTask":
                        ipi_needed, handled = self._is_ipi_needed(state)
                        out.append({
                            "state": mstg.vp.state[state].id,
                            "ipi_needed": ipi_needed
                        })
                        handled_sync |= handled

        for res in out:
            s = {True: "needs", False: "doesn't need"}[res['ipi_needed']]
            self._log.warn(f"State {res['state']} {s} an IPI.")

        self._set_step_data(out)
