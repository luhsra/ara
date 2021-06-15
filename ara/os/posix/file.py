from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
import os
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import IDInstance, register_instance, logger, CurrentSyscallCategories, add_edge_from_self_to, do_not_interpret_syscall


@dataclass
class File(IDInstance):
    path: str

    wanted_attrs = ["name", "path"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#08a2e0",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class FileSyscalls:

    # Map path -> File object
    # Note: chdir() is not supported and we can not detect multiple open() calls to the same file from different files.
    files = dict()

    # int open(const char *path, int oflag, ...);
    #
    # _ARA_open_syscall_ is the name of open() in the musl libc modification. This is required to circumvent the variable argument signature.
    @syscall(aliases={"_ARA_open_syscall_", "open64"},
             categories={SyscallCategory.create, SyscallCategory.comm},
             signature=(Arg('path', hint=SigType.value),
                        Arg('oflag', hint=SigType.value),
                        Arg('mode', hint=SigType.value)))
    def open(graph, abb, state, args, va):

        state = state.copy()
        cp = state.call_path
        file = None

        # If Category "Create": Create File Object
        if SyscallCategory.create in CurrentSyscallCategories.get():
            logger.debug("Execute SyscallCategory.create part of open()")
            if args.path == None:
                logger.warning("Could not get path argument in open(). The File object is now untrackable for interaction open() calls.")
            if args.path in FileSyscalls.files:
                file = FileSyscalls.files[args.path]
                logger.debug(f"open() call to already created File object: {file}")
            else:
                file = File(path=args.path,
                            name=(os.path.basename(args.path) if args.path != None else None)
                )
                
                state = register_instance(file, f"{file.name}", graph, abb, state, va)
                if args.path != None:
                    FileSyscalls.files[args.path] = file
            # Set the return value to the new filedescriptor (This file)
            va.assign_system_object(abb, file, callpath=cp)

        # If Category "comm": Create edge to the addressed File object
        if SyscallCategory.comm in CurrentSyscallCategories.get():
            logger.debug("Execute SyscallCategory.comm part of open()")
            file = FileSyscalls.files.get(args.path, None)
            if file != None:
                state = add_edge_from_self_to(graph, abb, state, file, "open()")
            else:
                logger.warning(f"File with path {args.path} not found!")

        return state