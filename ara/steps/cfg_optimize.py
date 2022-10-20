"""Container for CFGOptimize."""
from ara.graph import Graph
from .step import Step


class CFGOptimize(Step):
    """Apply basic LLVM optimizations that are needed for ARA."""

    def get_single_dependencies(self):
        return ['IRReader', 'FakeEntryPoint']

    @staticmethod
    def is_traceable():
        return False

    def run(self):
        self._step_manager.chain_step(
            {
                "name": "LLVMOptimization",
                "pass_list": "module(function(mem2reg,newgvn),ipsccp,function(dce,simplify-cfg))"
            }
        )
