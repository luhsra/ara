// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "thread_wrapper.h"
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/IRBuilder.h>

using namespace llvm;
namespace ara::step {

	std::string ThreadWrapper::get_description() {
		return "Create a wrapper function for a thread entry point which is part of the OS but not part of the static analysis"
		       "This Step will create wrappers for all thread entrypoint to handle correct thread termination.";
	}

	void ThreadWrapper::run() {
		Module& module = graph.get_module();
		LLVMContext& context = module.getContext();

		FunctionType* void_type_void = FunctionType::get(Type::getVoidTy(context), false);

		Function* z_thread_entry = Function::Create(void_type_void, Function::ExternalLinkage, "z_thread_entry", &module);
		Function* k_current_get = Function::Create(void_type_void, Function::ExternalLinkage, "k_current_get", &module);
		Function* k_thread_abort = Function::Create(void_type_void, Function::ExternalLinkage, "k_thread_abort", &module);

		// ZephyrStaticImpl z_context;

		// llvm::GlobalValue* symbol = nullptr;
		// llvm::StringRef thread_name = safe_deref(z_context.global).getName();
		// if (thread_name.consume_front("_k_thread_data_")) {
		// 	std::string obj_name = "_k_thread_obj_" + thread_name.str();
		// 	symbol = module.getNamedValue(obj_name);
		// }

		for (auto& function : module) { // Todo FIXME: only iter over threads
			std::cout << "ThreadWrapper: function:" << function.getName().str() << std::endl;
			if (function.getName().startswith("do_stuff")) {
				IRBuilder<> builder(context);
				BasicBlock& bb = *function.begin();
				Instruction* inst = &*bb.begin();
				builder.SetInsertPoint(inst);
				std::vector<Value*> ArgsV;s
				// builder.CreateCall(z_thread_entry, ArgsV);
				// logger.debug() << "add " << z_thread_entry->getName().str() << " to " << function.getName().str() << std::endl;

				BasicBlock& bb1 = function.back();
				Instruction* inst1 = &bb1.back();
				if (llvm::dyn_cast<llvm::ReturnInst>(inst1)) {
					builder.SetInsertPoint(inst1);
					builder.CreateCall(k_current_get, ArgsV);
					builder.CreateCall(k_thread_abort, ArgsV);
					logger.debug() << "add " << k_thread_abort->getName().str() << " to " << function.getName().str()
					               << std::endl;
				}
			}
		}
		
	}
} // namespace ara::step
