/**
 * Helper function for cython incompabilities. DO NOT USE IN OTHER C++-PARTS!
 */

#pragma once

#include "graph.h"
#include "option.h"
#include "step.h"

#include <llvm/Support/JSON.h>
#include <memory>

namespace ara::step {

	std::vector<const ara::option::Option*> repack(const step::StepFactory& step_fac) {
		std::vector<const ara::option::Option*> rep;
		for (const ara::option::Option& opt : step_fac.get_options()) {
			rep.emplace_back(&opt);
		}
		return rep;
	}

	template <class S>
	inline std::unique_ptr<step::StepFactory> make_step_fac() {
		return std::make_unique<StepTrait<S>>();
	}

	std::string get_dependencies(Step& step, std::string step_history_json) {
		// convert input
		auto val = llvm::json::parse(step_history_json);
		assert(val && "LLVM JSON parsing failed.");
		llvm::json::Array* arr = val->getAsArray();
		assert(arr && "input is not an array.");

		// convert output
		std::string foo;
		llvm::raw_string_ostream sstream(foo);
		sstream << llvm::json::Value(step.get_dependencies(*arr));
		return sstream.str();
	}
} // namespace ara::step

namespace ara::option {
	std::string get_type_args(const ara::option::Option* opt) { return opt->get_type_args(); }
} // namespace ara::option
