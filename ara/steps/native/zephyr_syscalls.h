// SPDX-FileCopyrightText: 2026 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>
#include <llvm/IR/Intrinsics.h>

namespace ara::step {
	class ZephyrSyscalls : public ConfStep<ZephyrSyscalls> {
	  private:
		using ConfStep<ZephyrSyscalls>::ConfStep;

		const static inline option::TOption<option::Bool> rename_syscalls_template{
		    "rename_syscalls", "Rename System Calls for specialization",
		    /* ty = */ option::Bool(),
		    /* default = */ false};
		option::TOptEntity<option::Bool> rename_syscalls;
		virtual void init_options() override;

		void RenameSystemcall(llvm::Module& module, llvm::CallInst* call);
		void RenameSystemcalls(llvm::Module& module);

	  public:
		virtual ~ZephyrSyscalls(){};
		static std::string get_name() { return "ZephyrSyscalls"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override { return {"MultiSSE"}; }

		virtual void run() override;
	};
} // namespace ara::step
