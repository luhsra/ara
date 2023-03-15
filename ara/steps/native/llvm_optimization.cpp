// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2020 Manuel Breiden
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
	std::string LLVMOptimization::get_description() {
		return "Modifies the CFG to prepare it for further usage."
		       "\n"
		       "Performs various LLVM Passes on the IR to simplify the CFG.";
	}

	void LLVMOptimization::init_options() {
		pass_list = pass_list_template.instantiate(get_name());
		opts.emplace_back(pass_list);
	}

	void LLVMOptimization::run() {
		// The PassManagers have no way to do debug logging to an own ostream. They use dbgs() which always prints to
		// stdout. Nevertheless, debug logging can be switched on and off, therefore we approximate this with our
		// log_level.
		if (!pass_list.get()) {
			logger.debug() << "pass_list argument is not given. Defaulting to do nothing then." << std::endl;
			return;
		}

		Logger::LogStream& error_logger = logger.err();
		Module& module = graph.get_module();

		// Initialize LLVM Managers
		ModulePassManager mpm;
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

		// Parse pass list from command line options
		if (auto error = pb.parsePassPipeline(mpm, StringRef(*pass_list.get()))) {
			logAllUnhandledErrors(std::move(error), error_logger.llvm_ostream(), "[Parse Error] ");
			error_logger.flush();
			std::string step_name = get_name();
			throw StepError(step_name, "Parse error in pass_list.");
		}

		mpm.run(module, mam);
		mam.clear();
	}
} // namespace ara::step
