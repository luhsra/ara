// vim: set noet ts=4 sw=4:

#include "agressive_dce.h"
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Scalar.h>

namespace ara::step {
    using namespace llvm;
	std::string AgressiveDCE::get_description() const {
		return "Performs Agressive Dead Code Elimination."
		       "\n"
		       "Uses the LLVM Agressive Dead Code Elimination pass to delete redundant instructions.";
	}

    std::vector<std::string> AgressiveDCE::get_dependencies() { return {"IRReader"}; }

	//void DeadCodeElimination::fill_options() { opts.emplace_back(dummy_option); }

	void AgressiveDCE::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);
        fpm.add(createAggressiveDCEPass()); 
        fpm.doInitialization();

    /* Loop over module's functions and count how many functions are altered by the Pass.
       fpm.run(function) returns true when a function was modified. */
        int n = 0;
        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn' given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            if(fpm.run(function)) {
                logger.debug() << "The function was modified." << std::endl;
                ++n;
            }
        }
		logger.debug() << "ADCE step finished successfully. " << n << "/" << module.getFunctionList().size() << " functions modified." << std::endl;
	}
} // namespace ara::step
