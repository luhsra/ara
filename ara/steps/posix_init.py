from pydoc import locate
from ara.graph.mix import ARA_ENTRY_POINT
from ara.os.os_base import ControlInstance
from ara.steps.instance_graph_stats import MissingInteractions
from ara.steps.util import current_step
from .step import Step
from .option import Option, Bool, Choice
from ara.os.os_util import assign_id
from ara.os.posix.posix_utils import POSIXInstance, PosixOptions, handle_static_soc
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

    enable_musl_syscalls = Option(
        name="enable_musl_syscalls",
        help="Toggle detection of native syscalls (e.g. Linux Syscalls) in the musl libc. "
             "Deactivating this feature will degrade the calls __syscall0, __syscall1, ... to stubs. "
             "In combination with the --no-stubs option the deactivation of this option will speed up the analysis. "
             "This feature can be pretty time intensive.",
        ty=Bool(),
        default_value=True
    )
    
    enable_missing_interaction_count = Option(
        name="enable_missing_interaction_count",
        help="Use this option in conjunction with InstanceGraphStats step to gather data about missing interactions",
        ty=Bool(),
        default_value=True
    )

    def get_single_dependencies(self):
        return ["POSIXStatic", "LLVMMap", "SVFAnalyses"]

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

        assert self._graph.instances != None, "Missing instance graph!"
        assert self._graph.cfg != None, "Missing control flow graph!"

        # avoid dependency conflicts, therefore import dynamically
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self._graph, current_step.tracer if hasattr(current_step, "tracer") else None)

        # Create static instances that are detected by POSIXStatic
        instances = self._graph.instances
        for v in self._graph.instances.vertices():
            static_inst_info = instances.vp.obj[v]
            instance_type = locate('ara.os.posix.' + static_inst_info["module"] + "." + static_inst_info["type"])
            instance = instance_type(name=None)
            instance.vertex = v
            instances.vp.obj[v] = instance
            instances.vp.label[v] = instance.name
            handle_static_soc(instances, v, reset_file_and_line=False)
            assign_id(instances, v)
            va.assign_system_object(static_inst_info["symbol"], instance)

        # Generate POSIX Main Thread
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

        # Set OS Model options
        PosixOptions.enable_musl_syscalls = self.enable_musl_syscalls.get()
        PosixOptions.enable_missing_interaction_count = self.enable_missing_interaction_count.get()
        if PosixOptions.enable_missing_interaction_count:
            MissingInteractions.activate()

        # Set musl syscall detection functions to stubs
        # if musl syscalls are disabled.
        if not PosixOptions.enable_musl_syscalls:
            for i in range(0, 7):
                musl_syscall_func = getattr(POSIX, "_musl_syscall" + str(i), None)
                if musl_syscall_func != None:
                    musl_syscall_func.is_stub = True