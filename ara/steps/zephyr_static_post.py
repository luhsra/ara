import graph_tool.util
from ara.graph import Graph
from .step import Step
from pydoc import locate
from ara.os.zephyr import ZephyrInstance, Thread, ISR, ZephyrKernel

class ZephyrStaticPost(Step):
    """Deserializes the dictionary encoded instance objects generated by the ZephyrStatic step."""

    def get_single_dependencies(self):
        return ["ZephyrStatic", "LLVMMap"]

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

        # There are no sensible defaults for those yet.
        # TODO: Use something other than abb zero for static instances.
        instances.vp.soc[v] = 0
        instances.vp.llvm_soc[v] = 0
        instances.vp.file[v] = ""
        instances.vp.line[v] = 0
        instances.vp.specialization_level[v] = ""


    def run(self):
        assert self._graph.instances is not None
        for instance in self._graph.instances.vertices():
            vals = self._graph.instances.vp.obj[instance]
            instance_type = locate('ara.os.zephyr.' + self._graph.instances.vp.label[instance])
            if instance_type is Thread or instance_type is ISR:
                vals['entry_abb'] = self._graph.cfg.get_entry_abb(self._graph.cfg.get_function_by_name(vals['entry_name']))
            inst = instance_type(**vals)
            self._graph.instances.vp.obj[instance] = inst

        # If there is a main, also add a thread for that. We don't no much about the properties of
        # the main thread, more info might be retrieved from the kconfig file
        # Also, there is no matching abb to give to the vertex
        main = graph_tool.util.find_vertex(self._graph.cfg, self._graph.cfg.vp['name'], 'main')
        if len(main) == 1:
            main_entry_abb = self._graph.cfg.get_entry_abb(main[0])
            main_thread = Thread(None, None, None, None, "main", main_entry_abb, (None, None, None), 0, 0, 0)
            ZephyrStaticPost.create_static_instance(self._graph.instances, "Main", main_thread, "__main", True)

        # Create a unique node for the Zephyr kernel.
        ZephyrStaticPost.create_static_instance(self._graph.instances, "Zephyr", ZephyrKernel(), "__kernel", False)

