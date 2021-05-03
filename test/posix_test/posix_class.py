
if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
from ara.os.posix.posix import POSIX
from ara.os.posix.syscall_set import syscall_set

def get_weak_alias(syscall):
    """ Returns the musl libc weak alias name version of the syscall name.

        For example: "pthread_create" -> "__pthread_create"

        For all names which start with a '_' there is no weak alias version.
        In this case this function will return just the input.
    """
    return "__" + syscall if syscall[0] != '_' else syscall

OS_interface = set({
    "get_special_steps",
    "has_dynamic_instances",
    "init",
    "interpret",
    "config",
    "get_name"
})

def main():

    # Check the OS interface
    for OS_method in OS_interface:
        fail_if(not hasattr(POSIX, OS_method), f"The OS interface method {OS_method} is missing in POSIX")

    posix_class_dir = dir(POSIX)
    for syscall in syscall_set:

        # Check if the syscall_set contains only strings
        fail_if(type(syscall) != str, f"syscall obj {syscall} in syscall_set is not a string. The actual type of this obj is {type(syscall)}.")

        # Check for a name clash
        fail_if(syscall in OS_interface, f"Name Clash detected. The syscall name {syscall} is part of the OS Interface in the POSIX class.")

        # Test normal syscall version
        fail_if(not hasattr(POSIX, syscall), f"syscall {syscall} from syscall_set is not in POSIX class")
        fail_if(not syscall in posix_class_dir, f"syscall {syscall} from syscall_set is not in dir(POSIX)")

        # Test weak alias syscall version (__{syscall}. eg. __pthread_create)
        weak_alias_version = get_weak_alias(syscall)
        fail_if(not hasattr(POSIX, weak_alias_version), f"weak_alias syscall version of {syscall} from syscall_set is not in POSIX class")
        fail_if(not weak_alias_version in posix_class_dir, f"weak_alias syscall version of {syscall} from syscall_set is not in dir(POSIX)")

        # Test for equality of the two POSIX Syscall impl.
        fail_if(getattr(POSIX, syscall) != getattr(POSIX, weak_alias_version), f"Syscall implementations of {syscall} and {weak_alias_version} differs")

if __name__ == '__main__':
    main()