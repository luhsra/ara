# SPDX-FileCopyrightText: 2022 Jan Neugebauer
#
# SPDX-License-Identifier: GPL-3.0-or-later

from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, assign_instance_to_argument, register_instance
from .file_descriptor import create_file_desc_of, FDType

@dataclass(eq = False)
class Pipe(IDInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#b95c1e",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class PipeSyscalls:

    # int pipe(int fildes[2]);
    @syscall(categories={SyscallCategory.create}, signal_safe=True,
             signature=(Arg('fildes_read', hint=SigType.instance),
                        Arg('fildes_write', hint=SigType.instance)))
    def ARA_pipe_syscall_(graph, state, cpu_id, args, va):
        
        new_pipe = Pipe(name=None)
        
        fildes_read = create_file_desc_of(new_pipe, FDType.READ)
        fildes_write = create_file_desc_of(new_pipe, FDType.WRITE)
        state = register_instance(new_pipe, new_pipe.name, "pipe()", graph, cpu_id, state)
        assign_instance_to_argument(va, args.fildes_read, fildes_read)
        assign_instance_to_argument(va, args.fildes_write, fildes_write)
        return state