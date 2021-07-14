from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, register_instance
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
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('fildes_read', hint=SigType.instance),
                        Arg('fildes_write', hint=SigType.instance)))
    def ARA_pipe_syscall_(graph, abb, state, args, va):
        
        new_pipe = Pipe(name=None)
        
        args.fildes_read = create_file_desc_of(new_pipe, FDType.READ)
        args.fildes_write = create_file_desc_of(new_pipe, FDType.WRITE)
        return register_instance(new_pipe, f"{new_pipe.name}", graph, abb, state)