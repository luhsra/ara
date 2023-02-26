"""Container for Stats"""
import json

from dataclasses import dataclass
from typing import Any, List


from .step import Step
from .util import open_with_dirs


@dataclass
class StatData:
    """Store a data point for statistics.

    Normally, if you want to store the number of "a", call the class
    constructor with StatData(key="a", value=your_actual_data).
    The key will be automatically prefixed with "num_" and get of description
    of "Number of a".
    If you don't want the prefix set "prefix_key" to False.
    If you want to give an own description give this by "desc".
    """
    key: str
    value: Any

    desc: str = None
    prefix_key: bool = True

    def __post_init__(self):
        if self.desc is None:
            self.desc = f"Number of {self.key}"
        if self.prefix_key:
            self.key = f"num_{self.key.lower()}"


class StatsStep(Step):
    """Get statistics from a specific graph."""

    def _print_and_store(self, data: List[StatData]):
        """Print, store and dump statistics data.

        See MSTGStats for correct usage.
        """
        # print
        for datum in data:
            self._log.info(f"{datum.desc}: {datum.value}")
        # store
        data_dict = {x.key: x.value for x in data}
        self._set_step_data(data_dict)

        if self.dump.get():
            with open_with_dirs(self.dump_prefix.get() + '.json', 'w') as f:
                json.dump(data_dict, f, indent=4)

    def run(self):
        self.fail("Do not call this step directly.")
