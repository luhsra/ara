// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "zephyr_thread_entry.h"
#include <llvm/IR/DerivedTypes.h>
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

		Type *k_thread = StructType::getTypeByName(context, "struct.k_thread");
		if(!k_thread) {
			logger.warning() << "struct.k_thread not found!" << std::endl;
			k_thread = llvm::Type::getInt32PtrTy(context);
		}

		PointerType* k_threadPtrTy = PointerType::getUnqual(k_thread);
		FunctionType* k_thread_abortFuncTy = FunctionType::get(Type::getVoidTy(context), {k_threadPtrTy}, false);

		Function* k_thread_abort = Function::Create(k_thread_abortFuncTy, Function::ExternalLinkage, "k_thread_abort", &module);

		Function *k_current_get = module.getFunction("k_current_get");
		if (!k_current_get) {
			logger.debug() << "Function k_current_get not found! Creating it!" << std::endl;

			FunctionType *k_tid_tFuncTy = FunctionType::get(k_threadPtrTy, false);
			k_current_get = Function::Create(k_tid_tFuncTy, Function::ExternalLinkage, "k_current_get", &module);
		}

		FunctionType* threadEntryFuncType = FunctionType::get(Type::getVoidTy(context), {
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context)}, false);
		
		PointerType* ptrThreadEntryFuncType = PointerType::getUnqual(threadEntryFuncType);

		std::vector<Type*> z_thread_entry_func_args{
			ptrThreadEntryFuncType,
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context),
			Type::getInt8PtrTy(context)
		};

		FunctionType* z_thread_entry_func_type = FunctionType::get(Type::getVoidTy(context), z_thread_entry_func_args, false);
		Function* z_thread_entry = Function::Create(z_thread_entry_func_type, Function::ExternalLinkage, "__ara_mock_z_thread_entry", &module);
    	llvm::BasicBlock *z_thread_entryBB = llvm::BasicBlock::Create(context, "entry", z_thread_entry);
		
		IRBuilder<> builder(context);
    	builder.SetInsertPoint(z_thread_entryBB);

		// create the call to the actual thread function
		Value* threadEntryFuncPtr = builder.CreatePointerCast(z_thread_entry->getArg(0), ptrThreadEntryFuncType);
		std::vector<Value*> thread_args{z_thread_entry->getArg(1), z_thread_entry->getArg(2), z_thread_entry->getArg(3)};
		builder.CreateCall(threadEntryFuncType, threadEntryFuncPtr, thread_args);
		
		// create the clean up code
		llvm::Value *thread_id = builder.CreateCall(k_current_get);
		builder.CreateCall(k_thread_abort, thread_id);

		// the z_thread_entry function does not return
		builder.CreateUnreachable();
	}
} // namespace ara::step
