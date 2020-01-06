class Option:
    def __init__(self, name, help, step_name, ty, glob=False):
        self._name = name
        self._help = help
        self._step_name = step_name
        self._ty = ty
        self._global = glob

    def get_name(self):
        return self._name

    def get_help(self):
        return self._help

    def is_global(self):
        return self._global

    def check(self, config):
        self._ty.check(config, self._step_name, self._name)

    def get_type_help(self):
        return self._ty.get_help()

    def get(self):
        return self._ty.get()


class OptionType:
    def __init__(self):
        self.valid = False
        self.value = None

    def check(self, config, step_name, name):
        val = config.get(name, None)
        if not val:
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
