// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include <cassert>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Utils.h>
#include <llvm/PassRegistry.h>

namespace ara::step {
    using namespace llvm;
	std::string CFGPreparation::get_description() const {
		return "Modifies the CFG to prepare it for further usage."
		       "\n"
		       "Performs various LLVM Passes on the IR to simplify the CFG.";
	}

    std::vector<std::string> CFGPreparation::get_dependencies() { return {"IRReader"}; }

	void CFGPreparation::fill_options() { opts.emplace_back(pass_list); }

	void CFGPreparation::run(graph::Graph& graph) {
        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);

        // Get pass list from command line options
        // TODO fix assert
        //assert(pass_list.get().second);
        std::vector<std::string> passes = pass_list.get().first;

        // Add the specified passes to the Function Pass Manager
        for (std::string pass_name : passes) {
            PassRegistry *pr = PassRegistry::getPassRegistry();
            if (pr != NULL) logger.debug() << "Pass Registry retrieved succesfully!!!" << std::endl;
            const PassInfo *pi = pr->getPassInfo(StringRef(pass_name));
            if (pr != NULL) logger.debug() << "Pass Registry retrieved succesfully!!!" << std::endl;
            logger.debug() << pi->getPassName().str() << std::endl;
        }

        //fpm.dumpPasses();

        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            fpm.run(function);
            // TODO Enable LLVM's "per-Pass-dump" and redirect LLVM ostream to ara's if necessary
            function.dump();
        }
		logger.debug() << this->get_name() << " step finished successfully. " << std::endl;
	}
} // namespace ara::step
