# TODO: make this to a dataclass, once Python 3.7 is available in Ubuntu LTS
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
        self._ty.check(config, self.step_name, self._name)

    def get(self):
        return self._ty.get()


class OptionType:
    def __init__(self):
        self.valid = False
        self.value = None

    @staticmethod
    def _get_value(config, step_name, name):
        assert '_per_step_config' in config

        pconf = config['_per_step_config']
        if step_name in pconf and name in pconf:
            return pconf[name]
        return config.get(name, None)

    def check(self, config, step_name, name):
        val = self._get_value(config, step_name, name)
        if not val:
            return
        self.value = self._validate(val, name)
        self.valid = True

    def get(self):
        return self.value, self.valid

    def _validate(self, val, name):
        raise NotImplementedError


class Bool(OptionType):
    def _validate(self, val, name):
        if not isinstance(bool, val):
            raise ValueError(f"{name}: {val} must be a boolean.")
        return val


class Integer(OptionType):
    def _validate(self, val, name):
        if not isinstance(int, val):
            raise ValueError(f"{name}: {val} must be an integer.")
        return val


class String(OptionType):
    def _validate(self, val, name):
        if not isinstance(str, val):
            raise ValueError(f"{name}: {val} must be a string.")
        return val


class Float(OptionType):
    def _validate(self, val, name):
        if not isinstance(float, val):
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


class List(list, OptionType):
    def __init__(self, ty):
        super().__init__()
        self.ty = ty

    def _validate(self, val, name):
        if not isinstance(list, val):
            raise ValueError(f"{name}: {val} must be a list.")
        for elem in val:
            ty = self.ty()
            ty._validate(elem, name)
        return val


class Choice(tuple, OptionType):
    def __init__(self, *args):
        super().__init__()
        self.choices = args

    def _validate(self, val, name):
        if val not in self.choices:
            raise ValueError(f"{name}: {val} must be one of {self.choices}.")
        return val
