from pickletools import pybytes
import graph_tool.util
import pyllco
from .step import Step
from pydoc import locate
from ara.os.zephyr import Queue, QueueType, ZephyrInstance, Thread, ZephyrKernel, ZEPHYR
from ara.os.os_base import ControlInstance
from .option import Option, String
from ara.util import KConfigFile

class ZephyrStaticPost(Step):
    """Deserializes the dictionary encoded instance objects generated by the ZephyrStatic step."""

    input_file = Option(name="input_file",
                         help="The input file",
                         ty=String())

    def get_single_dependencies(self):
        return ["ZephyrStatic", "LLVMMap", "SVFAnalyses"]

    @staticmethod
    def create_static_instance(instances, label: str, obj: ZephyrInstance, ident: str, sched_on: bool):
        v = instances.add_vertex()
        instances.vp.label[v] = label
        instances.vp.obj[v] = obj
        instances.vp.id[v] = ident
        # Static instances are always unique since they are properly initialized globals
        instances.vp.branch[v] = False
        instances.vp.loop[v] = False
        instances.vp.after_scheduler[v] = sched_on
        instances.vp.unique[v] = True
        instances.vp.is_control[v] = isinstance(obj, ControlInstance)

        # There are no sensible defaults for those yet.
        # TODO: Use something other than abb zero for static instances.
        instances.vp.soc[v] = 0
        instances.vp.llvm_soc[v] = 0
        instances.vp.file[v] = ""
        instances.vp.line[v] = 0
        instances.vp.specialization_level[v] = ""
        return v

    def run(self):
        assert self._graph.instances is not None

        # avoid dependency conflicts, therefore import dynamically
        from ara.steps import get_native_component
        ValueAnalyzer = get_native_component("ValueAnalyzer")
        va = ValueAnalyzer(self._graph)

        # Currently, we just look for a config with the same name as the app.ll
        ZEPHYR.config = KConfigFile(self.input_file.get()[:-3] + '.config')

        cfg = self._graph.cfg

        # Iterate over all statically created instances and convert their dict datatype to the matching datatype.
        # Also fill missing fields in control instances.
        for instance in self._graph.instances.vertices():
            instance_type = locate('ara.os.zephyr.' + self._graph.instances.vp.label[instance])
            inst = instance_type(**self._graph.instances.vp.obj[instance])
            if hasattr(inst, "symbol") and isinstance(inst.symbol, pyllco.Value):
                offset = None
                # Queue handling:
                if isinstance(inst, Queue) and inst.queue_type != QueueType.normal.value:
                    assert isinstance(inst.fake_gep, pyllco.GetElementPtrInst)
                    offset = [inst.fake_gep]
                va.assign_system_object(inst.symbol, inst, offset)
            if issubclass(instance_type, ControlInstance):
                function = cfg.get_function_by_name(inst.entry_name)
                inst.cfg = cfg
                inst.function = function

            # Mark the ids of all static instances as used. Since we use symbol names we know
            # them to be unique
            ZEPHYR.id_count[self._graph.instances.vp.id[instance]] = 1
            self._graph.instances.vp.obj[instance] = inst

        # If there is a main, also add a thread for that.
        # Also, there is no matching abb to give to the vertex
        # NOTE: main() can not be the entry point of a second normal thread because the signature
        # does not match
        main = graph_tool.util.find_vertex(cfg, cfg.vp['name'], 'main')
        if len(main) == 1:
            prio = int(ZEPHYR.config['CONFIG_MAIN_THREAD_PRIORITY'])
            stack_size = int(ZEPHYR.config['CONFIG_MAIN_STACK_SIZE'])
            main_thread = Thread(
                cpu_id=-1,
                cfg=cfg,
                artificial=False,
                function=cfg.get_function_by_name('main'),
                symbol=None,
                stack=None,
                stack_size=stack_size,
                entry_name="main",
                entry_params=(None, None, None),
                priority=prio,
                options=0,
                delay=0
            )
            ZephyrStaticPost.create_static_instance(self._graph.instances, "Thread", main_thread, "__main", True)

        # Create a unique node for the Zephyr kernel.
        kernel = ZephyrKernel(int(ZEPHYR.config['CONFIG_HEAP_MEM_POOL_SIZE']))
        ZEPHYR.kernel = ZephyrStaticPost.create_static_instance(self._graph.instances, "Zephyr", kernel, "__kernel", False)
