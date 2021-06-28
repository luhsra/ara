from dataclasses import dataclass
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, Arg
from .posix_utils import IDInstance, register_instance
from .file_descriptor import create_file_desc_of

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
             signature=(Arg('fildes', hint=SigType.instance),))
    def pipe(graph, abb, state, args, va):
        
        new_pipe = Pipe(name=None)
        
        args.fildes = create_file_desc_of(new_pipe)
        return register_instance(new_pipe, f"{new_pipe.name}", graph, abb, state)