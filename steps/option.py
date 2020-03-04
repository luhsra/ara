"""
Python side of options.

To use the option framework a step can request an Option object.
The Option object can then filled with an actual configuration with the
check function.
"""


class Option:
    """
    Option object to store information about the option as well as a
    specific configuration for the option.
    """
    def __init__(self, name, help, step_name, ty,
                 default_value=None, glob=False):
        """Create an Option.

        Arguments:
        name -- option name
        help -- option help message
        step_name -- step name that contains the option (for error printing)
        ty        -- option type (see the OptionType classes for types)

        Keyword arguments:
        default_value -- default value of the option (ATTENTION: this value is
                         unchecked. That means, that e.g. for a choice type it
                         is not checked if the default is a valid choice.)
        glob          -- is this option a global option? (needed for printing
                         of the help message)
        """
        self._name = name
        self._help = help
        self._step_name = step_name
        self._ty = ty
        self._global = glob
        self._default_value = default_value

    def get_name(self):
        """Get name of option."""
        return self._name

    def get_help(self):
        """Get help message of option."""
        return self._help

    def is_global(self):
        """Is the option global?"""
        return self._global

    def check(self, config: dict):
        """
        Apply an actual configuration to the option.

        Arguments:
        config -- a configuration dict. The option uses the value of
                  config[self.get_name] for its configuration.

        """
        self._ty.check(config, self._step_name, self._name)

    def get_type_help(self):
        """Get the type help message. What configuration values are allowed?"""
        return self._ty.get_help()

    def get(self):
        """
        Get the option value. This returns None, if the option is not set.
        """
        ret = self._ty.get()
        if ret is None:
            return self._default_value
        return ret


class OptionType:
    def __init__(self):
        self.valid = False
        self.value = None

    def check(self, config, step_name, name):
        val = config.get(name, None)
        if not val:
            self.valid = False
            return
        self.value = self._validate(val, name)
        self.valid = True

    def get(self):
        if self.valid:
            return self.value
        return None

    def _validate(self, val, name):
        raise NotImplementedError()

    def get_help(self):
        return self.__class__.__name__


class Bool(OptionType):
    def _validate(self, val, name):
        if not isinstance(val, bool):
            raise ValueError(f"{name}: {val} must be a boolean.")
        return val


class Integer(OptionType):
    def _validate(self, val, name):
        if not isinstance(val, int):
            raise ValueError(f"{name}: {val} must be an integer.")
        return val


class String(OptionType):
    def _validate(self, val, name):
        if not isinstance(val, str):
            raise ValueError(f"{name}: {val} must be a string.")
        return val


class Float(OptionType):
    def _validate(self, val, name):
        if not isinstance(val, float):
            raise ValueError(f"{name}: {val} must be a float.")
        return val


class Range(OptionType):
    def __init__(self, low, high):
        super().__init__()
        self.low = low
        self.high = high

    def _validate(self, val, name):
        if not (self.low < val < self.high):
            err = f"{name}: {val} has to be between {self.low} and {self.high}"
            raise ValueError(err)
        return val

    def get_help(self):
        return f"Range between {self.low} and {self.high}"


class List(OptionType):
    def __init__(self, ty):
        super().__init__()
        self.ty = ty

    def _validate(self, val, name):
        if not isinstance(val, list):
            raise ValueError(f"{name}: {val} must be a list.")
        for elem in val:
            ty = self.ty()
            ty._validate(elem, name)
        return val

    def get_help(self):
        return f"List of {self.ty.get_help()}s"


class Choice(OptionType):
    def __init__(self, *args):
        super().__init__()
        self.choices = args

    def _validate(self, val, name):
        if val not in self.choices:
            raise ValueError(f"{name}: {val} must be one of {self.choices}.")
        return val

    def get_help(self):
        choices = ', '.join([f'"{x}"' for x in self.choices])
        return f"Any of {choices}"
