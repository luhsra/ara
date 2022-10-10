#include "remove_sysfunc_body.h"

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

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

	void RemoveSysfuncBody::run() {

		std::set<std::string> os_syscalls = this->graph.get_os().get_syscall_names();

		// converts e.g. sleep.5 -> sleep
		auto get_name_without_suffix = [](llvm::Function& func) { return func.getName().rsplit('.').first.str(); };

		// Delete the body of all system functions
		Module& module = graph.get_module();
		if (drop_llvm_suffix.get().value_or(false)) {
			std::map<std::string, std::vector<Function*>> functs;
			for (Function& func : module) {
				if (os_syscalls.find(get_name_without_suffix(func)) != os_syscalls.end()) {
					logger.debug() << "Remove function body of " << func.getName().str() << std::endl;
					func.deleteBody();
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
