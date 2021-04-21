
import html
from dataclasses import dataclass, field
from enum import Enum, IntEnum
from typing import Any, Union, Optional, Dict
from ara.graph import SyscallCategory, SigType

from ..os_util import syscall, assign_id, Arg
from .posix_utils import POSIXInstance, debug_log, handle_soc, add_initial_instance_to_state


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
    file_offset: int # Cursor Position in the file 

class StreamBufferMode(Enum):
    UNBUFFERED = 0
    FULLY_BUFFERED = 1
    LINE_BUFFERED = 2

class StreamOrientation(Enum):
    NO_ORIENTATION = 0
    WIDE_ORIENTED = 1
    BYTE_ORIENTED = 2

@dataclass
class Stream(POSIXInstance):
    FILE_pointer: int
    connected_to_file: Optional[File]
    buffer_mode: StreamBufferMode
    #buffer_size: Optional[int]
    orientation: StreamOrientation
    #encoding_rule: Any # Only applies when WIDE_ORIENTED
    file_position_indicator: int = 0

    def as_dot(self):
        wanted_attrs = ["name", "FILE_pointer", "connected_to_file", "buffer_mode", "orientation", "file_position_indicator"]
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
        return '.'.join(map(str, ["Stream",
                                  self.name,
                                  self.FILE_pointer,
                                  self.connected_to_file,
                                  self.buffer_mode,
                                  self.orientation,
                                  self.file_position_indicator
                                 ]))

def generate_std_streams(state):
    
    standard_input = Stream(cfg=None, abb=None, call_path=None, name="standard input", vidx=None,
                            FILE_pointer = None,
                            connected_to_file = None,
                            file_position_indicator = None,
                            buffer_mode = None, # We can not know! Fully buffered iff no reference to an interactive device 
                            orientation = StreamOrientation.NO_ORIENTATION
    )

    standard_output = Stream(cfg=None, abb=None, call_path=None, name="standard output", vidx=None,
                            FILE_pointer = None,
                            connected_to_file = None,
                            file_position_indicator = None,
                            buffer_mode = None, # We can not know! Fully buffered iff no reference to an interactive device 
                            orientation = StreamOrientation.NO_ORIENTATION
    )

    standard_error = Stream(cfg=None, abb=None, call_path=None, name="standard error", vidx=None,
                            FILE_pointer = None,
                            connected_to_file = None,
                            file_position_indicator = None,
                            buffer_mode = None, # We can not know! The standard only says this stream is not fully buffered.
                            orientation = StreamOrientation.NO_ORIENTATION
    )

    add_initial_instance_to_state(state, standard_input, "standard input")
    add_initial_instance_to_state(state, standard_output, "standard output")
    add_initial_instance_to_state(state, standard_error, "standard error")


class FileSyscalls:

    # void *malloc(size_t size);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('size', hint=SigType.value),))
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

        return state

    # int chdir(const char *path);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('path', hint=SigType.symbol),))
    def chdir(graph, abb, state, args, va):

        debug_log("found chdir() syscall")
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

        return state

    # char *strcpy(char *restrict s1, const char *restrict s2);
    @syscall(categories={SyscallCategory.create},
             signature=(Arg('s1', hint=SigType.symbol),
                        Arg('s2', hint=SigType.symbol)))
    def strcpy(graph, abb, state, args, va):

        debug_log("found strcpy() syscall")
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Chdir"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = File(graph.cfg, abb=None, call_path=None, name="strcpy",
                                        vidx = v,
                                        absolute_pathname = "STRCPY file",
                                        file_type = FileType.REGULAR
                                        
        )

        assign_id(state.instances, v)

        return state

    @syscall(categories={SyscallCategory.create},
             signature=(Arg('value1', hint=SigType.value),
                        Arg('value2', hint=SigType.value),
                        Arg('value3', hint=SigType.value),
                        Arg('value4', hint=SigType.value)))
    def __muldc3(graph, abb, state, args, va):
        debug_log("GOT __muldc3")
        state = state.copy()

        # instance properties
        cp = state.call_path

        v = state.instances.add_vertex()
        state.instances.vp.label[v] = "Chdir"

        #new_cfg = cfg.get_entry_abb(cfg.get_function_by_name("task_function"))
        #assert new_cfg is not None
        # TODO: when do we know that this is an unique instance?
        handle_soc(state, v, graph.cfg, abb)
        state.instances.vp.obj[v] = File(graph.cfg, abb=None, call_path=None, name="strcpy",
                                        vidx = v,
                                        absolute_pathname = "STRCPY file",
                                        file_type = FileType.REGULAR
                                        
        )

        assign_id(state.instances, v)

        return state