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
    2. self.consts: a dict for the actually call graph aware constant value
       the key for that is the call path (a tuple of all call abbs). The value
       is the llvm constant. If the value is not ambiguous it is stored under
       the default key 'tuple()'. If the value is ambiguous, this key is not
       present or contains an llvm.ConstantTokenNone.
    """
    def __init__(self, attributes, constant):
        self.consts = {tuple(): constant}
        self.attributes = attributes

    def __repr__(self):
        ambi = len(self.consts) >= 2
        return (f"Argument({repr(self.consts[tuple()])}, ambiguous={ambi}, "
                f"{repr(self.attributes)})")

    def __str__(self):
        ambi = len(self.consts) >= 2
        args = [f'{x}: {str(y)}' for x, y in self.consts.items()]
        return (f"Argument({args}, ambiguous={ambi}, "
                f"{repr(self.attributes)})")

    def _get_call_path(self, call_path):
        g = graph_tool.GraphView(call_path.graph, reversed=True)
        path = []
        for e in graph_tool.search.dfs_iterator(g, call_path.node):
            path.append(g.vp.cfglink[e.source()])
        return tuple(path)

    def add_variant(self, call_path, constant):
        """Add another callpath, constant pair."""
        self.consts[call_path] = constant

    def get(self, call_path=None, raw=False):
        """Get the constant value as Python object (str, int, ...) under the
        specified call_path.

        Keyword arguments:
            call_path -- The path of the value that should be retrieved
                         (default: the empty default path for an ambiguous
                         value).
            raw       -- Return the raw llvm.Constant object without
                         interpreting it.
        """
        if call_path is not None:
            cp = self._get_call_path(call_path)
            if cp in self.consts:
                constant = self.consts[cp]
            else:
                constant = self.consts[tuple()]

        if raw:
            return constant

        if isinstance(constant, pyllco.Function):
            return constant.get_name()
        return constant.get(attrs=self.attributes)
