// vim: set noet ts=4 sw=4:

#include "cfg_prep.h"
#include "logging.h"
#include <cassert>
#include <llvm/Support/Error.h>
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
        const bool dbg_flag = log_level.get() && (*log_level.get() == "debug");
        const bool verify_passes = false;
        Logger::LogStream& crit_logger = logger.crit();
        Module& module = graph.get_module();

        // Initialize LLVM Managers
        ModulePassManager mpm(dbg_flag);
        ModuleAnalysisManager mam(dbg_flag);
        FunctionAnalysisManager fam(dbg_flag);
        CGSCCAnalysisManager cgsccam(dbg_flag);
        LoopAnalysisManager lam(dbg_flag);

        // Initialize PassBuilder and register Analyses
        PassBuilder pb;
        pb.registerModuleAnalyses(mam);
        pb.registerCGSCCAnalyses(cgsccam);
        pb.registerFunctionAnalyses(fam);
        pb.registerLoopAnalyses(lam);
        pb.crossRegisterProxies(lam, fam, cgsccam, mam);

        // Parse pass list from command line options
        if (auto error = pb.parsePassPipeline(mpm, StringRef(*pass_list.get()), verify_passes, dbg_flag)) {
            logAllUnhandledErrors(std::move(error), crit_logger.llvm_ostream(), "[Parse Error] ");
            crit_logger.flush();
            abort();
        }

        for (auto& function : module) {
            if (function.empty())
                continue;

            // Removes OptNone Attribute that prevents optimization if -Xclang -disable-O0-optnone isn't given
            if (function.hasOptNone()) {
                function.removeFnAttr(Attribute::OptimizeNone);
            }

            // TODO Add an option for enabling IR dump on console
            //function.dump();
        }
        mpm.run(module, mam);
        /*for (auto& function : module) {
            if (function.empty())
                continue;

            // TODO Add an option for enabling IR dump on console
            //function.dump();
        }*/

        mam.clear();
		logger.debug() << this->get_name() << " step finished successfully. " << std::endl;
	}
} // namespace ara::step
