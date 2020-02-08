// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include <cassert>
#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Transforms/Utils.h>

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
        // Initialize LLVM Managers
        ModulePassManager mpm(true);
        ModuleAnalysisManager mam;
        FunctionAnalysisManager fam;
        CGSCCAnalysisManager cgsccam;
        LoopAnalysisManager lam;
        // Initialize PassBuilder and register Analyses
        PassBuilder pb;
        pb.registerModuleAnalyses(mam);
        pb.registerCGSCCAnalyses(cgsccam);
        pb.registerFunctionAnalyses(fam);
        pb.registerLoopAnalyses(lam);
        pb.crossRegisterProxies(lam, fam, cgsccam, mam);

        assert(pass_list.get().second);
        logger.debug() << "Specified pass list is: " << pass_list.get().first << std::endl;

        // Parse pass list from command line options
        // TODO Fix pass_list
        if (auto error = pb.parsePassPipeline(mpm, StringRef(pass_list.get().first), true, true)) {
            abort();
        }

        //fpm.dumpPasses();

        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            // TODO Enable LLVM's "per-Pass-dump" and redirect LLVM ostream to ara's if necessary
            function.dump();
        }
        mpm.run(module, mam);
        for (auto& function : module) {
            if (function.empty())
                continue;

            // TODO Enable LLVM's "per-Pass-dump" and redirect LLVM ostream to ara's if necessary
            function.dump();
        }
		logger.debug() << this->get_name() << " step finished successfully. " << std::endl;
	}
} // namespace ara::step
