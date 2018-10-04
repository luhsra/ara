import graph


class Logic:
    def __init__(self, *args):
        self._objects = []
        for arg in args:
            self._objects.append(arg)

    def __len__(self):
        return len(self._objects)

    def __getitem__(self, number):
        return self._objects[number]

    def __iter__(self):
        return iter(self._objects)


class Or(Logic):
    pass
    def __iter__(self):
        return iter(self._objects[0:1])


class And(Logic):
    pass


class Passage:
    _config = {}

    def __init__(self, config):
        self._config = config

    def get_dependencies(self):
        return []

    def get_name(self):
        return self.__class__.__name__

    def get_description(self) -> str:
        return self.__doc__

    def run(self, g: graph.PyGraph):
        raise("Not implemented.")
