import pyllco

import graph_tool
import graph_tool.search

from collections import namedtuple

# make this a data class once Ubuntu has a newer Python
CallPath = namedtuple('CallPath', ['graph', 'node'])

class Argument:
    """Combined type for a function argument.

    See arguments.h for the C++ side.

    An argument consists of two parts:
    1. self.attributes: an LLVM attribute set that defines argument attributes
       like a "zero extension"
    2. self.values: a dict for the actually call graph aware value.
       The key for that is the call path (a tuple of all call abbs). The value
       is the llvm value. If the value is not ambiguous it is stored under
       the default key 'tuple()'. If the value is ambiguous, this key is not
       present or contains an llvm.ConstantTokenNone.
    """
    def __init__(self, attributes, value):
        self.values = {tuple(): value}
        self.attributes = attributes

    def __repr__(self):
        ambi = len(self.values) >= 2
        return (f"Argument({repr(self.values[tuple()])}, ambiguous={ambi}, "
                f"{repr(self.attributes)})")

    def __str__(self):
        ambi = len(self.values) >= 2
        args = [f'{x}: {str(y)}' for x, y in self.values.items()]
        return (f"Argument({args}, ambiguous={ambi}, "
                f"{repr(self.attributes)})")

    def _get_call_path(self, call_path):
        g = graph_tool.GraphView(call_path.graph, reversed=True)
        path = []
        for e in graph_tool.search.dfs_iterator(g, call_path.node):
            path.append(g.vp.cfglink[e.source()])
        return tuple(path)

    def add_variant(self, call_path, value):
        """Add another callpath, value pair."""
        self.values[call_path] = value

    def get(self, call_path=None, raw=False):
        """Get the value as Python object (str, int, ...) under the specified
        call_path.

        Keyword arguments:
            call_path -- The path of the value that should be retrieved
                         (default: the empty default path for an ambiguous
                         value).
            raw       -- Return the raw llvm.Value object without
                         interpreting it.

        Return value:
        1. The interpreted constant value if possible, None otherwise.
        2. If raw is set, the uninterpreted llvm.Value.
        """
        if call_path is not None:
            cp = self._get_call_path(call_path)
            if cp in self.values:
                value = self.values[cp]
            else:
                value = self.values[tuple()]

        if raw:
            return value

        if isinstance(value, pyllco.Constant):
            if isinstance(value, pyllco.Function):
                return value.get_name()
            return value.get(attrs=self.attributes)

        return None


class Arguments(list):
    """Store a list of argument together with a special return value."""

    def set_return_value(self, ret_value):
        self.return_value = ret_value

    def get_return_value(self):
        return self.return_value
