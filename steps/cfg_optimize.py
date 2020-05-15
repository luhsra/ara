"""Container for CFGOptimize."""
import graph

from native_step import Step
from .option import Option, Integer


class CFGOptimize(Step):
    """Apply basic LLVM optimizations that are needed for ARA."""

    def get_dependencies(self):
        return ['IRReader']

    def run(self, g: graph.Graph):
        self._step_manager.chain_step(
            {
                "name": "LLVMOptimization",
                "pass_list": "module(function(mem2reg,newgvn),ipsccp,function(dce,simplify-cfg))"
            }
        )
