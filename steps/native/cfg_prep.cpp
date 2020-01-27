// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include <cassert>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/Transforms/Utils.h>
#include <llvm/Support/CommandLine.h>

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
        // Get pass list from options and feed it to the LLVM Argument Parser
        assert(pass_list.get().second);
        std::vector<std::string> passes = pass_list.get().first;
        // TODO cast passes to char**
        //cl::ParseCommandLineOptions(passes.size(), passes);

        // Create gloabal variable for the parser
        cl::list<Pass_opts> PassOptList(cl::desc("Available Passes:"),
               cl::values(
                  clEnumVal(dce         , "Dead Code Elimination"),
                  clEnumVal(constprop   , "Constant Propagation"),
                  clEnumVal(sccp        , "Sparse Conditional Constant Propagation")));

        Module& module = graph.get_module();
        legacy::FunctionPassManager fpm(&module);

        for (std::string pass_name : passes) {
            std::cout << pass_name << std::endl; 
            // TODO parse pass names and create and add them to the FPM
        }

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
