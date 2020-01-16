// vim: set noet ts=4 sw=4:

#include "reassociate.h"
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Utils.h>

namespace ara::step {
    using namespace llvm;
	std::string Reassociate::get_description() const {
		return "Reassociates commutative expressions."
		       "\n"
		       "Uses the LLVM reassociate pass to reassociate commutative expressions for a better constant propagation.";
	}

    std::vector<std::string> Reassociate::get_dependencies() { return {"IRReader"}; }

	//void Mem2Reg::fill_options() { opts.emplace_back(dummy_option); }

	void Reassociate::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);
        fpm.add(createReassociatePass()); 
        fpm.doInitialization();

    /* Loop over module's functions and count how many functions are altered by the Pass.
       fpm.run(function) returns true when a function was modified. */
        int n = 0;
        int i = 0;
        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
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
		logger.debug() << this->get_name() << " step finished successfully. " << n << "/" << module.getFunctionList().size() << " functions modified." << std::endl;
	}
} // namespace ara::step
