import math

class Timings:
    """This class contains all timing information for the minexample application.
    For each ABB there needs to be a function returning their min and max execution times."""

    @staticmethod
    def get_timings(abb_name, context):
        # f = getattr(Timings, str(abb_name) + '_timings', None)
        # if f is not None:
        #     return f(context)
        # return (0, math.inf)
        return (4, 6)
    
    @staticmethod
    def get_min_time(abb_name, context):
        res = Timings.get_timings(abb_name, context)
        return res[0]

    @staticmethod
    def get_max_time(abb_name, context):
        res = Timings.get_timings(abb_name, context)
        return res[1]

    @staticmethod
    def ABB1_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB2_timings(context):
        return (0, None)

    @staticmethod
    def ABB3_timings(context):
        return (0, None)
    
    def ABB1_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB4_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB5_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB6_timings(context):
        return (0, None)

    @staticmethod
    def ABB7_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB8_timings(context):
        return (0, None)

    @staticmethod
    def ABB9_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB10_timings(context):
        return (0, None)

    @staticmethod
    def ABB11_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB12_timings(context):
        return (0, None)

    @staticmethod
    def ABB13_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB14_timings(context):
        return (0, None)

    @staticmethod
    def ABB15_timings(context):
        return (0, None)
    
    @staticmethod
    def ABB16_timings(context):
        return (0, None)