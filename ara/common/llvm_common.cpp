// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "common/llvm_common.h"

#include "common/exceptions.h"

#include <llvm/IR/DebugInfoMetadata.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

namespace ara {
	std::string print_type(Type* argument) {
		std::string type_str;
		raw_string_ostream rso(type_str);
		argument->print(rso);
		return rso.str() + "\"\n";
	}

	bool is_intrinsic(const Function& func) {
		if (func.getIntrinsicID() == llvm::Intrinsic::donothing || func.getIntrinsicID() == llvm::Intrinsic::dbg_addr ||
		    func.getIntrinsicID() == llvm::Intrinsic::dbg_declare ||
		    func.getIntrinsicID() == llvm::Intrinsic::dbg_label ||
		    func.getIntrinsicID() == llvm::Intrinsic::dbg_value) {
			return true;
		}
		return false;
	}

	bool is_call_to_intrinsic(const Instruction& inst) {
		if (const CallBase* call = dyn_cast<CallBase>(&inst)) {
			if (call->isInlineAsm()) {
				return true;
			}
			const Function* func = call->getCalledFunction();
			if (func == nullptr)
				return false;
			return is_intrinsic(*func);
		}
		return false;
	}

	std::pair<std::filesystem::path, unsigned> get_source_location(const llvm::Instruction& inst) {
		const auto& debug_loc = inst.getDebugLoc();
		if (debug_loc) {
			if (const auto* scope = llvm::dyn_cast<llvm::DIScope>(debug_loc.getScope())) {
				std::filesystem::path source = std::filesystem::path(scope->getDirectory().str()) /
				                               std::filesystem::path(scope->getFilename().str());
				unsigned line = debug_loc.getLine();
				return std::make_pair(source, line);
			}
		}
		throw LLVMError("Debug location unknown");
	}
} // namespace ara
