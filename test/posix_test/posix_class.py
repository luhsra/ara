
if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import init_test, fail_if
from ara.os.posix.posix import POSIX, _POSIXSyscalls
from ara.os.posix.syscall_set import syscall_set

def get_musl_weak_alias(syscall):
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
    "get_name",
    "detected_syscalls",
    "is_syscall"
})

def main():
    """Test the POSIX OS model class."""

    # Check the OS interface
    for OS_method in OS_interface:
        fail_if(not hasattr(POSIX, OS_method), f"The OS interface method {OS_method} is missing in POSIX")

    posix_class_dir = dir(POSIX)
    posix_detected_syscalls = POSIX.detected_syscalls()
    for syscall in syscall_set:

        # Check if the syscall_set contains only strings
        fail_if(type(syscall) != str, f"syscall obj {syscall} in syscall_set is not a string. The actual type of this obj is {type(syscall)}.")

        # Check for a name clash
        fail_if(syscall in OS_interface, f"Name Clash detected. The syscall name {syscall} is part of the OS Interface in the POSIX class.")

        # Test normal syscall version
        fail_if(not hasattr(POSIX, syscall), f"syscall {syscall} from syscall_set is not in POSIX class")
        fail_if(not syscall in posix_class_dir, f"syscall {syscall} from syscall_set is not in dir(POSIX)")
        fail_if(posix_detected_syscalls[syscall].get_name() != syscall, f"syscall {syscall} from syscall_set is not in POSIX.detected_syscalls()")

        # If the syscall is not implemented:
        if not hasattr(_POSIXSyscalls, syscall):
            musl_weak_alias = get_musl_weak_alias(syscall)
            fail_if(list(posix_detected_syscalls[syscall].aliases) != [musl_weak_alias], f"Alias for syscall stub {syscall} is not set correctly!")

        for alias in posix_detected_syscalls[syscall].aliases:
            # Test for right name
            fail_if(posix_detected_syscalls[syscall].get_name() != syscall, f"Alias {alias} of {syscall} from syscall_set is not in POSIX.detected_syscalls()")
            # Test for equality of the two POSIX Syscall impl.
            fail_if(posix_detected_syscalls[syscall] != posix_detected_syscalls[alias], f"Syscall implementations of {syscall} and {alias} differs")

    

if __name__ == '__main__':
    main()