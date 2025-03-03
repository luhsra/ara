// SPDX-FileCopyrightText: 2024 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:
#include "value_analyzer_state.h"

#include "callpath.h"
#include "common/exceptions.h"
#include <string>
#include <iostream>

namespace ara::value_analyzer {
	std::string get_function_name(const llvm::CallBase& callsite) {
		auto* func = callsite.getCalledFunction();
		if (func == nullptr) {
			auto* value = callsite.getCalledOperand();
			if (const auto* alias = llvm::dyn_cast<llvm::GlobalAlias>(value)) {
				if (llvm::isa<llvm::Function>(alias->getAliasee())) {
					return alias->getName().str();
				}
				assert(false && "Found alias that points not to a function.");
			}
			assert(false && "Callee is neither a function nor an alias. Is it a function pointer?");
		} else {
			return func->getName().str();
		}
	}

	ValueLocation::ValueLocation(const llvm::CallBase& callsite, const graph::CallPath& callpath,
	                             const unsigned argument_nr)
	    : callsite(callsite.getName().str()), function(get_function_name(callsite)),
	      callpath(callpath.print(/* call_site = */ false, /* instruction = */ false, true)), arg_nr(argument_nr) {

		// if the callgraph is empty, try getting the caller
		if (this->callpath.compare("CallPath()") == 0) {
			std::stringstream cp;
			cp << "Callpath(" << callsite.getCaller()->getName().str() << ")";
			this->callpath = cp.str();
		}

		// if the callsite is empty, we could try getting the line number
		//if (this->callsite.compare("") == 0) {
		//	this->callsite = std::to_string(callsite.getDebugLoc()->getLine());
		//}


		std::cout << "Callpath: " << this->callpath << std::endl;
	}

	ValueLocation::ValueLocation(const llvm::json::Object& obj) {
		const auto callsite = obj.getString("inst");
		if (!callsite) {
			throw JSONError();
		}
		this->callsite = callsite->str();

		const auto function = obj.getString("func");
		if (!function) {
			throw JSONError();
		}
		this->function = function->str();

		const auto callpath = obj.getString("call_path");
		if (!callpath) {
			throw JSONError();
		}
		this->callpath = callpath->str();

		const auto arg_nr = obj.getInteger("nr");
		if (!arg_nr) {
			throw JSONError();
		}
		this->arg_nr = *arg_nr;
	}

	bool ValueLocation::operator<(const ValueLocation& other) const {
		std::stringstream a, b;
		a << this->callsite << this->function << this->callpath << this->arg_nr;
		b << other.callsite << other.function << other.callpath << other.arg_nr;
		return  a.str() < b.str();
	}

	std::string ValueLocation::as_json() const {
		llvm::json::Object key{{"inst", callsite}, {"func", function}, {"call_path", callpath}, {"nr", arg_nr}};
		std::string res;
		llvm::raw_string_ostream sstream(res);
		sstream << llvm::json::Value(std::move(key));
		return sstream.str();
	}
} // namespace ara::value_analyzer
