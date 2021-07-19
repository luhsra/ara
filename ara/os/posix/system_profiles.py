
from .posix_utils import NotSet


LINUX_PROFILE = dict({
    ("default_sched_priority", 0),
    ("default_sched_policy", "SCHED_OTHER"),
    ("default_inheritsched", True)  # PTHREAD_INHERIT_SCHED
})

POSIX_STD_PROFILE = dict({
    ("default_sched_priority", NotSet()),
    ("default_sched_policy", NotSet()),
    ("default_inheritsched", NotSet())
})


SYSTEM_PROFILES = dict((
    ("Linux", LINUX_PROFILE),
    ("POSIX", POSIX_STD_PROFILE)
))

class Profile:
    """This static class wraps the current system profile.
    
    Call Profile.get() to get the current system profile.
    """
    profile: dict = None

    @classmethod
    def get_value(cls, key: str) -> dict:
        return cls.profile[key]

    @classmethod
    def set(cls, profile: str):
        cls.profile = SYSTEM_PROFILES[profile]