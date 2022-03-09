from ara.graph.mix import ARA_ENTRY_POINT
from ara.os.os_base import ControlInstance
from .step import Step
from .option import Option, Bool, Choice
from ara.os.os_util import assign_id
from ara.graph import SyscallCategory
from ara.os.posix.posix_utils import MainThread, POSIXInstance, PosixOptions, StaticInitSyscalls, handle_static_soc
from ara.os.posix.thread import Thread
from ara.os.posix.system_profiles import SYSTEM_PROFILES, Profile
from ara.os.posix.posix import POSIX

class POSIXInit(Step):
    """Initializes the POSIX OS Model."""

    # Options for the POSIX OS Model
    system_profile = Option(
        name="system_profile",
        help="The POSIX system profile that is in use. "
             "The default option is \"POSIX\" that lets this OS model behave in a standard conformant way. "
             "Set this option to \"Linux\" if your target OS is Linux. "
             "Currently the system profile describes default scheduling parameters of new threads.",
        ty=Choice(*SYSTEM_PROFILES.keys()),
        default_value="POSIX"
    )

    enable_static_init_detection = Option(
        name="enable_static_init_detection",
        help="Toggle detection of PTHREAD_MUTEX_INITIALIZER. "
             "Sometimes it is useful to disable this feature. "
             "E.g. if the value analyzer can not retrieve the Mutex handle. "
             "In this case every Mutex interaction call creates a new useless Mutex in the Instance Graph.",
        ty=Bool(),
        default_value=True
    )

    enable_musl_syscalls = Option(
        name="enable_musl_syscalls",
        help="Toggle detection of native syscalls (e.g. Linux Syscalls) in the musl libc. "
             "Deactivating this feature will degrade the calls __syscall0, __syscall1, ... to stubs. "
             "In combination with the --no-stubs option the deactivation of this option will speed up the analysis. "
             "This feature can be pretty time intensive.",
        ty=Bool(),
        default_value=True
    )
    

    def get_single_dependencies(self):
        return ["LLVMMap"]

    def register_default_instance(self, inst: POSIXInstance, label: str):
        """Writes a new default instance to the InstanceGraph.
        
        E.g. the Main Thread is available in all programs.
        """
        instances = self._graph.instances
        v = instances.add_vertex()
        inst.vertex = v
        instances.vp.obj[v] = inst
        instances.vp.label[v] = label
        instances.vp.is_control[v] = isinstance(inst, ControlInstance)
        handle_static_soc(instances, v)
        assign_id(instances, v)

    def run(self):
        
        # Activate system profile
        Profile.set(self.system_profile.get())

        # Generate POSIX Main Thread
        assert self._graph.instances != None, "Missing instance graph!"
        assert self._graph.cfg != None, "Missing control flow graph!"
        cfg = self._graph.cfg
        main_thread = Thread(cpu_id=-1,
                             cfg=cfg,
                             artificial=False,
                             function=cfg.get_function_by_name(ARA_ENTRY_POINT),
                             function_name="ARA_ENTRY_POINT",
                             sched_priority=Profile.get_value("default_sched_priority"),
                             sched_policy=Profile.get_value("default_sched_policy"),
                             inherited_sched_attr=None,
                             name="Main Thread"
        )
        self.register_default_instance(main_thread, "Main Thread")
        MainThread.set(main_thread)

        # Set OS Model options
        PosixOptions.enable_static_init_detection = self.enable_static_init_detection.get()
        PosixOptions.enable_musl_syscalls = self.enable_musl_syscalls.get()

        # Disable SyscallCategory.create in StaticInitSyscalls
        # if static init detection is disabled.
        if not PosixOptions.enable_static_init_detection:
            for comm_func in StaticInitSyscalls.get_comms():
                comm_func.categories = {SyscallCategory.comm}

        # Set musl syscall detection functions to stubs
        # if musl syscalls are disabled.
        if not PosixOptions.enable_musl_syscalls:
            for i in range(0, 7):
                musl_syscall_func = getattr(POSIX, "_musl_syscall" + str(i), None)
                if musl_syscall_func != None:
                    musl_syscall_func.is_stub = True