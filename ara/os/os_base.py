class OSBase:
    config = {}

    @classmethod
    def get_name(cls):
        return cls.__name__
