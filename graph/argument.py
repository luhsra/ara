import pyllco

class Argument:
    """Combined type for a function argument.

    See arguments.h for the C++ side.

    """
    def __init__(self, constant, attributes):
        self.constant = constant
        self.attributes = attributes

    def __repr__(self):
        return f"Argument({repr(self.constant)}, {repr(self.attributes)})"

    def is_function(self):
        return isinstance(self.constant, pyllco.Function)

    def get(self):
        if self.is_function():
            return self.constant.get_name()
        return self.constant.get(attrs=self.attributes)
