"""Container for FunctionLabels."""
import graph

from native_step import Step


class FunctionLabels(Step):
    """Label each function as system relevant or irrelevant."""
    def get_dependencies(self):
        return ['ABB_MergeStep']

    def run(self, g: graph.PyGraph):
        assert self._config['os'] == 'freertos', \
            'SchedulerRelation analysis in OSEK is meaningless'

        self._log.info("Running SchedulerRelation analysis")
