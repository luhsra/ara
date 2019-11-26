// vim: set noet ts=4 sw=4:

#include "const_prop.h"
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Scalar.h>

namespace ara::step {
    using namespace llvm;
	std::string ConstProp::get_description() const {
		return "Performs Constant Propagation."
		       "\n"
		       "Uses the LLVM Simple Constant Propagation pass to substitute the values of known constants inside of expressions.";
	}

    std::vector<std::string> get_dependencies() { return {"IRReader"}; }

	//void ConstantPropagation::fill_options() { opts.emplace_back(dummy_option); }

	void ConstProp::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);
        fpm.add(createConstantPropagationPass()); 
        //fpm.doInitialization();

    /* Loop over module's functions and count how many functions are altered by the ConstProp Pass.
       fpm.run(function) returns true when a function was modified. */
        int n = 0;
        for (auto& function : module) {
            if (function.empty())
                continue;
            if(fpm.run(function)) {
                logger.debug() << "A function was modified." << std::endl;
                ++n;
            }
        }
		logger.debug() << "Constant Propagation step finished succesfully. " << n << "/" << module.getFunctionList().size() << " functions modified." << std::endl;
	}
} // namespace ara::step
