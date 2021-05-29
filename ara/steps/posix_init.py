from .step import Step
from ara.os.os_util import assign_id
from ara.os.posix.thread import Thread

class POSIXInit(Step):
    """Initializes the POSIX OS Model."""

    def get_single_dependencies(self):
        return []

    def register_default_instance(self, inst, label: str):
        """Writes a new default instance to the InstanceGraph.
        
        E.g. the Main Thread is available in all programs.
        """
        #inst.cfg = None
        #inst.abb = None 
        #inst.call_path = None 
        #inst.vidx = None

        instances = self._graph.instances
        v = instances.add_vertex()
        instances.vp.obj[v] = inst
        instances.vp.label[v] = label

        instances.vp.branch[v] = False
        instances.vp.loop[v] = False
        instances.vp.recursive[v] = False
        instances.vp.after_scheduler[v] = False
        instances.vp.usually_taken[v] = True
        instances.vp.unique[v] = True

        # The following values are not applicable
        instances.vp.soc[v] = 0
        instances.vp.llvm_soc[v] = 0
        instances.vp.file[v] = "N/A"
        instances.vp.line[v] = 0
        instances.vp.specialization_level[v] = "N/A"

        assign_id(instances, v)

    def run(self):
        
        # Generate POSIX default instances
        assert self._graph.instances != None, "Missing instance graph!"
        assert self._graph.cfg != None, "Missing control flow graph!"
        main_thread = Thread(entry_abb = None,
                             function = "main",
                             name="Main Thread",
                             is_regular=False
        )
        self.register_default_instance(main_thread, "Main Thread")
