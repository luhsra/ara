#include "native_step_pyx.h"
#include "step.h"

#include <llvm/Support/JSON.h>
#include <llvm/Support/raw_ostream.h>
#include <sstream>

namespace ara::step {
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
