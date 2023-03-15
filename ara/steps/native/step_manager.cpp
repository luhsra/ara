// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "step.h"
#include "step_pyx.h"

#include <llvm/Support/JSON.h>
#include <llvm/Support/raw_ostream.h>
#include <sstream>

namespace ara::step {
	void StepManager::change_global_config(const llvm::json::Value& config) {
		std::string foo;
		llvm::raw_string_ostream sstream(foo);
		sstream << config;
		step_manager_change_global_config(step_manager, sstream.str().c_str());
	}

	void StepManager::chain_step(const llvm::json::Value& step_config) {
		std::string foo;
		llvm::raw_string_ostream sstream(foo);
		sstream << step_config;
		step_manager_chain_step(step_manager, sstream.str().c_str());
	}

	void StepManager::chain_step(const std::string& step_name) { chain_step(step_name.c_str()); }

	void StepManager::chain_step(const char* step_name) {
		llvm::json::Value v(llvm::json::Object{{"name", step_name}});
		chain_step(v);
	}

	std::string StepManager::get_execution_id() { return step_manager_get_execution_id(step_manager); }
} // namespace ara::step
