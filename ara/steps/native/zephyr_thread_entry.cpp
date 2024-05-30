// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "zephyr_thread_entry.h"
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/IRBuilder.h>

using namespace llvm;
namespace ara::step {

	std::string ZephyrThreadEntry::get_description() {
		return "Create a wrapper function for the thread entry point which is part of the OS but is not in the scope of the static analysis"
		       "This step will create the z_thread_entry function needed to handle correct thread termination.";
	}

	void ZephyrThreadEntry::run() {
		Module& module = graph.get_module();
		LLVMContext& context = module.getContext();

		FunctionType* void_type = FunctionType::get(Type::getVoidTy(context), false);

		Function* k_thread_abort = Function::Create(void_type, Function::ExternalLinkage, "k_thread_abort", &module);

		Function *k_current_get = module.getFunction("k_current_get");
		if (!k_current_get) {
			logger.debug() << "Function k_current_get not found! Creating it!" << std::endl;
			Type *k_thread = StructType::getTypeByName(context, "struct.k_thread");
			if(!k_thread) {
				logger.warning() << "struct.k_thread not found!" << std::endl;
				k_thread = llvm::Type::getInt32PtrTy(context);
			}
			FunctionType *k_tid_t_func_ret = FunctionType::get(k_thread, false);
			k_current_get = Function::Create(k_tid_t_func_ret, Function::ExternalLinkage, "k_current_get", &module);
		}

		FunctionType* threadEntryFuncType = FunctionType::get(Type::getVoidTy(context), {
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context)}, false);
		
		std::vector<Type*> z_thread_entry_func_args{
			threadEntryFuncType,
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context)
		};

		FunctionType* z_thread_entry_func_type = FunctionType::get(Type::getVoidTy(context), z_thread_entry_func_args, false);
		
		Function* z_thread_entry = Function::Create(z_thread_entry_func_type, Function::ExternalLinkage, "__ara_mock_z_thread_entry", &module);
    	llvm::BasicBlock *z_thread_entryBB = llvm::BasicBlock::Create(context, "entry", z_thread_entry);
		
		IRBuilder<> builder(context);
    	builder.SetInsertPoint(z_thread_entryBB);
		
		Value* threadEntryFuncPtr = builder.CreatePointerCast(z_thread_entry->getArg(0), PointerType::getUnqual(threadEntryFuncType));

		// create the call to the actual thread function
		std::vector<Value*> thread_args{z_thread_entry->getArg(1), z_thread_entry->getArg(2), z_thread_entry->getArg(3)};
		builder.CreateCall(threadEntryFuncType, threadEntryFuncPtr, thread_args);
		
		// create the clean up code
		llvm::Value *thread_id = builder.CreateCall(k_current_get);
		builder.CreateCall(k_thread_abort, thread_id);

		// the z_thread_entry function does not return
		builder.CreateUnreachable();
	}
} // namespace ara::step
