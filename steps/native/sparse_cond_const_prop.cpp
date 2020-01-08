// vim: set noet ts=4 sw=4:

#include "sparse_cond_const_prop.h"
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Scalar.h>

namespace ara::step {
    using namespace llvm;
	std::string SparseCondConstProp::get_description() const {
		return "Performs Constant Propagation."
		       "\n"
		       "Uses the LLVM Simple Constant Propagation pass to substitute the values of known constants inside of expressions.";
	}

    std::vector<std::string> SparseCondConstProp::get_dependencies() { return {"IRReader", "Mem2Reg"}; }

	//void ConstantPropagation::fill_options() { opts.emplace_back(dummy_option); }

	void SparseCondConstProp::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);
        fpm.add(createSCCPPass()); 
        fpm.doInitialization();

    /* Loop over module's functions and count how many functions are altered by the SparseCondConstProp Pass.
       fpm.run(function) returns true when a function was modified. */
        int n = 0;
        int i = 0;
        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn' given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            logger.debug() << "Function " << i << " before pass execution:\n" << std::endl;
            function.dump();
            if(fpm.run(function)) {
                logger.debug() << "The function was modified.\n" << std::endl;
                ++n;
            }
            logger.debug() << "Function " << i << " after pass execution:\n" << std::endl;
            function.dump();
            ++i;
        }
		logger.debug() << "Sparse Conditional Constant Propagation step finished successfully. " << n << "/" << module.getFunctionList().size() << " functions modified." << std::endl;
	}
} // namespace ara::step
