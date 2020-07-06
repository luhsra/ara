"""
Python side of options.

To use the option framework a step can request an Option object.
The Option object needs to be instantiated. The option instance can be filled
with an actual configuration (check() function) and asked for this value
(get()).
"""


class OptionInst:
    """
    An instance of an option that can hold values and give them back.
    """
    def __init__(self, opt_type_store, default_value, name, step_name):
        self._ty = opt_type_store
        self._default_value = default_value
        self._name = name
        self._step_name = step_name

    def check(self, config: dict):
        """
        Apply an actual configuration to the option.

        Arguments:
        config -- a configuration dict. The option uses the value of
                  config[self.get_name] for its configuration.

        """
        self._ty.check(config, self._step_name, self._name)

    def get(self):
        """
        Get the option value. This returns None, if the option is not set.
        """
        ret = self._ty.get()
        if ret is None:
            return self._default_value
        return ret


class Option:
    """
    Option object to store information about the option as well as a
    specific configuration for the option.
    """
    def __init__(self, name, help, ty,
                 default_value=None, is_global=False):
        """Create an Option.

        Arguments:
        name -- option name
        help -- option help message
        ty        -- option type (see the OptionType classes for types)

        Keyword arguments:
        default_value -- default value of the option (ATTENTION: this value is
                         unchecked. That means, that e.g. for a choice type it
                         is not checked if the default is a valid choice.)
        is_global     -- is this option a global option? (needed for printing
                         of the help message). A global option is an option
                         that is accepted by all steps.
        """
        self._name = name
        self._help = help
        self._ty = ty
        self._global = is_global
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

    def get_type_help(self):
        """Get the type help message. What configuration values are allowed?"""
        return self._ty.get_help()

    def instantiate(self, step_name):
        return OptionInst(self._ty.instantiate(), self._default_value,
                          self._name, step_name)


class OptionType:
    class OptionTypeStore:
        def __init__(self, opt_type):
            self.valid = False
            self.value = None
            self._ty = opt_type

        def check(self, config, step_name, name):
            val = config.get(name, None)
            if val is None:
                self.valid = False
                return
            self.value = self._ty._validate(val, name)
            self.valid = True

        def get(self):
            if self.valid:
                return self.value
            return None

    def instantiate(self):
        return self.OptionTypeStore(self)

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
