// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Utils.h>

namespace ara::step {
    using namespace llvm;
	std::string CFG_Preperation::get_description() const {
		return "Modifies the CFG to prepare it for further usage."
		       "\n"
		       "Performs various LLVM Passes on the IR to simplify the CFG.";
	}

    std::vector<std::string> CFG_Preperation::get_dependencies() { return {"IRReader"}; }

	void CFG_Preperation::fill_options() { opts.emplace_back(pass_list); }

	void CFG_Preperation::run(graph::Graph& graph) {
        // Get pass list from options
        assert(pass_list.get().second);
        std::vector<std::string> passes = pass_list.get().first;

        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);

        for (std::string pass_name : passes) {
            std::cout << pass_name << std::endl; 
            // TODO parse pass names and create and add them to the FPM
        }

        /* Loop over module's functions and count how many functions are altered by the Pass.
        fpm.run(function) returns true when a function was modified. */
        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            fpm.run(function);
        }
		logger.debug() << this->get_name() << " step finished successfully. " << std::endl;
	}
} // namespace ara::step
