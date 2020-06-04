"""Container for CFGOptimize."""
from ara.graph import Graph
from native_step import Step
from .option import Option, Integer


class CFGOptimize(Step):
    """Apply basic LLVM optimizations that are needed for ARA."""

    def get_dependencies(self):
        return ['IRReader', 'FakeEntryPoint']

    def run(self, g: Graph):
        self._step_manager.chain_step(
            {
                "name": "LLVMOptimization",
                "pass_list": "module(function(mem2reg,newgvn),ipsccp,function(dce,simplify-cfg))"
            }
        )
