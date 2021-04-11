
import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc


class FileType(Enum):
    REGULAR = 0
    DIRECTORY = 1
    # TODO: Add all file types

@dataclass
class File(POSIXInstance):
    absolute_pathname: str
    file_type: FileType
    # TODO: Add further file mode data

    def as_dot(self):
        wanted_attrs = ["name", "absolute_pathname", "file_type"]
        attrs = [(x, str(getattr(self, x))) for x in wanted_attrs]
        sublabel = '<br/>'.join([f"<i>{k}</i>: {html.escape(v)}"
                                    for k, v in attrs])

        return {
            "shape": "box",
            "fillcolor": "#6fbf87",
            "style": "filled",
            "sublabel": sublabel
        }

    def get_maximal_id(self):
        # TODO: use a better max_id
        return '.'.join(map(str, ["Thread",
                                  self.name,
                                  self.absolute_pathname,
                                  self.file_type,
                                 ]))

@dataclass
class FileDescriptor(POSIXInstance):
    value: int
    connected_to_file: Optional[File]


class FileSyscalls:

    # void *malloc(size_t size);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('size', hint=SigType.value)),)
    def malloc(graph, abb, state, args, va):
        debug_log("found malloc() syscall")

        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Malloc"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = File(graph.cfg, abb=None, call_path=None, name="Size file: " + str(args.size),
                                        vidx = v,
                                        absolute_pathname = str(args.size),
                                        file_type = FileType.REGULAR
                                        
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state


    @syscall(categories={SyscallCategory.create})
    def pause(graph, abb, state, args, va):

        debug_log("found pause() syscall")

        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Pause"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = File(graph.cfg, abb=None, call_path=None, name="Super File",
                                        vidx = v,
                                        absolute_pathname = "Mega File",
                                        file_type = FileType.REGULAR
                                        
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state

    # int chdir(const char *path);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('path', hint=SigType.symbol),))
    def chdir(graph, abb, state, args, va):

        print("Im here")
        debug_log("found chdir() syscall")
        print("after this")
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Chdir"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = File(graph.cfg, abb=None, call_path=None, name="Super File in " + str(args.path),
                                        vidx = v,
                                        absolute_pathname = "Mega File",
                                        file_type = FileType.REGULAR
                                        
        )

        assign_id(state.instances, v)

        state.next_abbs = []

        return state