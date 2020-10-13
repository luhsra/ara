import math

class Timings:
    """This class contains all timing information for the minexample application.
    For each ABB there needs to be a function returning their min and max execution times."""

    @staticmethod
    def get_timings(cfg, abb, context):
        abb_name = cfg.vp.name[abb]
        if cfg.vp.type[abb] == 0b1:
            return (0, 0)
        f = getattr(Timings, str(abb_name) + '_timings', None)
        if f is not None:
            return f(context)
        # return (0, math.inf)
        return (4, 6)
    
    @staticmethod
    def get_min_time(cfg, abb, context):
        res = Timings.get_timings(cfg, abb, context)
        return res[0]

    @staticmethod
    def get_max_time(cfg, abb, context):
        res = Timings.get_timings(cfg, abb, context)
        return res[1]

    @staticmethod
    def ABB4_timings(context):
        return (1, 2)
    
    @staticmethod
    def ABB0_timings(context):
        return (1, 2)
    
