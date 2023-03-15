# SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

if __name__ == '__main__':
    __package__ = 'test.posix_test'

from ..init_test import fail_if
from ara.os.posix.posix import POSIX, _POSIXSyscalls
from ara.os.posix.syscall_set import syscall_set

def weak_alias_existing(syscall):
    """Returns True if a musl weak alias is existing for syscall.
    
    This is the case when there is no '_' at the beginning of the name.
    """
    return syscall[0] != '_'

def get_musl_weak_alias(syscall):
    """Returns the musl libc weak alias name of the syscall name.

    For example: "pthread_create" -> "__pthread_create"

    For all names which start with a '_' there is no weak alias
    but this function will return the non existing weak alias version in this case.
    Use weak_alias_existing() to check if a weak alias is available.
    """
    return "__" + syscall

OS_interface = set({
    "get_special_steps",
    "has_dynamic_instances",
    "interpret",
    "config",
    "get_name",
    "syscalls",
    "is_syscall"
})

def main():
    """Test the POSIX OS model class."""

    # Check the OS interface
    for OS_method in OS_interface:
        fail_if(not hasattr(POSIX, OS_method), f"The OS interface method {OS_method} is missing in POSIX")

    posix_class_dir = dir(POSIX)
    posix_syscalls = POSIX.syscalls
    for syscall in syscall_set:

        # Check if the syscall_set contains only strings
        fail_if(type(syscall) != str, f"syscall obj {syscall} in syscall_set is not a string. The actual type of this obj is {type(syscall)}.")

        # Check for a name clash
        fail_if(syscall in OS_interface, f"Name Clash detected. The syscall name {syscall} is part of the OS Interface in the POSIX class.")

        # Test normal syscall version
        fail_if(not hasattr(POSIX, syscall), f"syscall {syscall} from syscall_set is not in POSIX class")
        fail_if(not syscall in posix_class_dir, f"syscall {syscall} from syscall_set is not in dir(POSIX)")
        fail_if(posix_syscalls[syscall].get_name() != syscall, f"syscall {syscall} from syscall_set is not in POSIX.detected_syscalls()")

        # If the syscall is not implemented:
        if not hasattr(_POSIXSyscalls, syscall):
            alias_available = weak_alias_existing(syscall)
            musl_weak_alias = get_musl_weak_alias(syscall)
            if alias_available:
                fail_if(list(posix_syscalls[syscall].aliases) != [musl_weak_alias], f"Alias for syscall stub {syscall} is not set correctly!")
            else:
                fail_if(list(posix_syscalls[syscall].aliases) != [], f"Alias for syscall stub {syscall} is not set correctly!")
                fail_if(posix_syscalls.get(musl_weak_alias, None) != None, f"Alias for syscall stub {syscall} is not set correctly!")

        for alias in posix_syscalls[syscall].aliases:
            fail_if(alias not in posix_syscalls, f"Alias {alias} not in POSIX.syscalls")
            # Test for right name
            fail_if(posix_syscalls[syscall].get_name() != syscall, f"Alias {alias} of {syscall} from syscall_set is not in POSIX.syscalls")
            # Test for equality of the two POSIX Syscall impl.
            fail_if(posix_syscalls[syscall] != posix_syscalls[alias], f"Syscall implementations of {syscall} and {alias} differs")

    

if __name__ == '__main__':
    main()
