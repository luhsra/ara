import pyllco

class Argument:
    """Combined type for a function argument.

    See arguments.h for the C++ side.

    """
    def __init__(self, attributes, constant):
        self.consts = {tuple(): constant}
        self.attributes = attributes

    def __repr__(self):
        ambi = len(self.consts) >= 2
        return (f"Argument({repr(self.consts[tuple()])}, ambiguous={ambi}, "
                f"{repr(self.attributes)})")

    def add_variant(self, call_path, constant):
        self.consts[call_path] = constant

    def is_function(self):
        return isinstance(self.constant, pyllco.Function)

    def get(self, call_path=None):
        if self.is_function():
            return self.constant.get_name()
        return self.constant.get(attrs=self.attributes)
