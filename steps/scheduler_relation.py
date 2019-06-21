"""Container for SchedulerRelation."""
import graph

from native_step import Step


class SchedulerRelation(Step):
    """Check relation of scheduler start to instance creation.

    In FreeRTOS the call to the scheduler can happen before or after
    instance creation. This step traverses all syscalls and marks them as
    called before or after scheduler start.

    Syscalls executed from tasks and ISRs are always after scheduler start, so
    only the main function is checked.
    """
    def get_dependencies(self):
        return ['ABB_MergeStep']

    def run(self, g: graph.PyGraph):
        assert self._config['os'] == 'freertos', \
            'SchedulerRelation analysis in OSEK is meaningless'

        self._log.info("Running SchedulerRelation analysis")
