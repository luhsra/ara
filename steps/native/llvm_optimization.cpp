// vim: set noet ts=4 sw=4:

#include "llvm_optimization.h"

#include "logging.h"

#include <cassert>
#include <llvm/IR/PassManager.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Support/Error.h>
#include <llvm/Transforms/Utils.h>

namespace ara::step {
	using namespace llvm;
	std::string LLVMOptimization::get_description() const {
		return "Modifies the CFG to prepare it for further usage."
		       "\n"
		       "Performs various LLVM Passes on the IR to simplify the CFG.";
	}

	std::vector<std::string> LLVMOptimization::get_dependencies() { return {"IRReader"}; }

	void LLVMOptimization::fill_options() { opts.emplace_back(pass_list); }

	void LLVMOptimization::run(graph::Graph& graph) {
		// The PassManagers have no way to do debug logging to an own ostream. They use dbgs() which always prints to
		// stdout. Nevertheless, debug logging can be switched on and off, therefore we approximate this with our
		// log_level.
		const bool dbg_flag = logger.get_level() == LogLevel::DEBUG;
		const bool verify_passes = false;
		if (!pass_list.get()) {
			logger.debug() << "pass_list argument is not given. Defaulting to do nothing then." << std::endl;
			return;
		}

		Logger::LogStream& error_logger = logger.err();
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
			logAllUnhandledErrors(std::move(error), error_logger.llvm_ostream(), "[Parse Error] ");
			error_logger.flush();
			std::string step_name = get_name();
			throw StepError(step_name, "Parse error in pass_list.");
		}

		mpm.run(module, mam);
		mam.clear();
	}
} // namespace ara::step
