class Timings:
    """This class contains all timing information for the minexample application.
    For each ABB there needs to be a function returning their min and max execution times."""

    def get_timings(self, abb_nr, context):
        f = getattr(self, 'ABB_' + abb_nr + '_timings', None)
        if f is not None:
            return f(context)
        return (0, None)
    
    def get_min_time(self, abb_nr, context):
        res = self.get_timings(abb_nr, context)
        return res[0]

    def get_max_time(self, abb_nr, context):
        res = self.get_timings(abb_nr, context)
        return res[1]

    def ABB_1_timings(self, context):
        return (0, None)