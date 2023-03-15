// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "option.h"
#include "step.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

#include <Python.h>
#include <graph.h>

namespace ara::step {
	class RemoveSysfuncBody : public ConfStep<RemoveSysfuncBody> {
	  private:
		using ConfStep<RemoveSysfuncBody>::ConfStep;

		const static inline option::TOption<option::Bool> drop_llvm_suffix_template{
		    "drop_llvm_suffix",
		    "If true this step also removes system functions that have a llvm suffix. "
		    "An example for syscalls with a llvm suffix is: \"sleep.5\" or \"wait.3\". "
		    "If you do not need this feature, set this option to false to increase performance of this step.",
		    /* ty = */ option::Bool(),
		    /* default = */ true};
		option::TOptEntity<option::Bool> drop_llvm_suffix;
		virtual void init_options();
		void remove_llvm_suffix_syscall(llvm::Function& func, const std::string& name_without_suffix,
		                                llvm::Module& module);

	  public:
		static std::string get_name() { return "RemoveSysfuncBody"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {drop_llvm_suffix_template}; }

		virtual std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		virtual void run() override;
	};
} // namespace ara::step
