// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "remove_sysfunc_body.h"

#include <common/llvm_common.h>
#include <os.h>
#include <pyllco.h>
#include <vector>

namespace ara::step {
	using namespace llvm;

	std::string RemoveSysfuncBody::get_description() {
		return "Remove function bodies of system functions that the OS model interprets.\n"
		       "This cleans unnecessary information in different graphs.\n";
	}

	void RemoveSysfuncBody::init_options() {
		drop_llvm_suffix = drop_llvm_suffix_template.instantiate(get_name());
		opts.emplace_back(drop_llvm_suffix);
	}

	void RemoveSysfuncBody::remove_llvm_suffix_syscall(Function& func, const std::string& name_without_suffix,
	                                                   Module& module) {
		Function* actual_syscall = module.getFunction(name_without_suffix);

		bool use_found = false;
		for (auto use = func.use_begin(); use != func.use_end(); ++use) {
			if (const Instruction* instr = llvm::dyn_cast<const Instruction>(use->getUser())) {
				use_found = true;
				std::ostringstream loc_str;
				try {
					const auto& [source, line] = get_source_location(*instr);
					loc_str << std::filesystem::canonical(source) << ":" << line;
				} catch (const LLVMError& e) {
					loc_str << "<location unknown (no debug info?)>";
				}
				logger.debug() << "Update use of " << func.getName().str() << "() in " << loc_str.str() << std::endl;
			} else {
				logger.warning() << "Use of " << func.getName().str() << " is not an instruction" << std::endl;
			}
		}
		if (use_found) {
			logger.warning() << "Update all " << func.getName().str() << "() calls to " << name_without_suffix << "()"
			                 << std::endl;
			func.replaceAllUsesWith(actual_syscall);
		}
	}

	void RemoveSysfuncBody::run() {

		std::set<std::string> os_syscalls = this->graph.get_os().get_syscall_names();

		// converts e.g. sleep.5 -> sleep
		auto get_name_without_suffix = [](llvm::Function& func) { return func.getName().rsplit('.').first.str(); };

		// Delete the body of all system functions
		Module& module = graph.get_module();
		if (drop_llvm_suffix.get().value_or(false)) {
			for (Function& func : module) {
				auto name_without_suffix = get_name_without_suffix(func);
				if (os_syscalls.find(name_without_suffix) != os_syscalls.end()) {
					logger.debug() << "Remove function body of " << func.getName().str() << std::endl;
					func.deleteBody();
					if (!func.getName().equals(name_without_suffix)) {
						remove_llvm_suffix_syscall(func, name_without_suffix, module);
					}
				}
			}
		} else {
			for (const auto& syscall : os_syscalls) {
				Function* func = module.getFunction(syscall);
				if (func != nullptr) {
					logger.debug() << "Remove function body of " << syscall << std::endl;
					func->deleteBody();
				}
			}
		}

		// Dump modified LLVM IR
		if (*dump.get()) {
			std::string ir_file = *dump_prefix.get() + "ll";
			llvm::json::Value ir_printer_conf(llvm::json::Object{{"name", "IRWriter"}, {"ir_file", ir_file}});
			step_manager.chain_step(ir_printer_conf);
		}
	}
} // namespace ara::step
