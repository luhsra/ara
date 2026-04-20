// SPDX-FileCopyrightText: 2026 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "zephyr_syscalls.h"

#include <regex>
#include <set>

namespace ara::step {
	using namespace llvm;

	std::string ZephyrSyscalls::get_description() {
		return "Rewrite System call sites to enable specialization";
	}

	void ZephyrSyscalls::init_options() {
		rename_syscalls = rename_syscalls_template.instantiate(get_name());
		opts.emplace_back(rename_syscalls);
	}

	Step::OptionVec ZephyrSyscalls::get_local_options() { return {rename_syscalls_template}; }

	/*! Rename each systemcall to a basic block specific pendant.
	 *
	 * Each systemcall is renamed to systemcallname_basicblockname.
	 */
	void ZephyrSyscalls::RenameSystemcall(Module& module, CallInst* call) {
		Function* func = call->getCalledFunction();
		FunctionType* func_ty = func->getFunctionType();

		std::stringstream name;
		name << func->getName().str() << "_" << call->getParent()->getName().str();

		Function* x = Function::Create(func_ty, Function::ExternalLinkage, name.str(), &module);
		call->setCalledFunction(x);

		logger.debug() << "Rename function " << name.str() << std::endl;
	}

	/*! Find all systemcalls and rename them via RenameSystemcall(). */
	void ZephyrSyscalls::RenameSystemcalls(Module& module) {
		logger.info() << "Execute RenameSystemcalls" << std::endl;

		std::set<std::string> SystemCalls = this->graph.get_os().get_syscall_names();
		// only a subset of system calls are renamed
		std::regex re("yield");

		for (auto& function : module) {
			for (auto& bb : function) {
				for (auto& inst : bb) {
					if (CallInst* callInst = dyn_cast<CallInst>(&inst)) {
						Function* func = callInst->getCalledFunction();
						if (!func)
							continue;
						// Found a Call. Is it a systemcall?
						for (auto syscall : SystemCalls) {
							if (func->getName() == syscall && std::regex_search(syscall, re)) {
								RenameSystemcall(module, callInst);
								break;
							}
						}
					}
				}
			}
		}
	}

	void ZephyrSyscalls::run() {
		logger.info() << "Execute ZephyrSyscalls step." << std::endl;

		Module& module = graph.get_module();

		const auto& rename = rename_syscalls.get();
		assert(rename);
		if (*rename) {
			RenameSystemcalls(module);
		}
	}
} // namespace ara::step
