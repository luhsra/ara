"""This module contains all system profiles."""

from ..os_util import DefaultArgument


LINUX_PROFILE = dict({
    ("default_sched_priority", 0),
    ("default_sched_policy", "SCHED_OTHER"),
    ("default_inheritsched", True)  # PTHREAD_INHERIT_SCHED
})

POSIX_STD_PROFILE = dict({
    ("default_sched_priority", DefaultArgument()),
    ("default_sched_policy", DefaultArgument()),
    ("default_inheritsched", DefaultArgument())
})


SYSTEM_PROFILES = dict((
    ("Linux", LINUX_PROFILE),
    ("POSIX", POSIX_STD_PROFILE)
))

class Profile:
    """This static class wraps the current system profile.
    
    Call Profile.get_value() to get the value of <key> in the current system profile.
    """
    profile: dict = None

    @classmethod
    def get_value(cls, key: str) -> dict:
        return cls.profile[key]

    @classmethod
    def set(cls, profile: str):
        cls.profile = SYSTEM_PROFILES[profile]