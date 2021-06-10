from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import IDInstance, logger, handle_soc, register_instance

@dataclass
class Pipe(IDInstance):
    wanted_attrs = ["name", "num_id"]
    dot_appearance = {
        "shape": "box",
        "fillcolor": "#b95c1e ",
        "style": "filled"
    }

    def __post_init__(self):
        super().__init__()

class PipeSyscalls:

    # int pipe(int fildes[2]);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('fildes', hint=SigType.instance),))
    def pipe(graph, abb, state, args, va):
        
        new_pipe = Pipe(name=None)
        
        args.fildes = new_pipe
        return register_instance(new_pipe, f"{new_pipe.name}", graph, abb, state, va)