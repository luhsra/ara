// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2021 Kenny Albes
// SPDX-FileCopyrightText: 2023 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "fake_entry_point.h"

#include <llvm/IR/IRBuilder.h>
using namespace llvm;
namespace ara::step {

	std::string FakeEntryPoint::get_description() {
		return "Create a fake entry point which calls all constructors before the real entry point is reached. "
		       "This is task of the startup code and needs to be simulated for correctness and instance detection.";
	}

	void FakeEntryPoint::run() {
		static int run = 0;
		if (run++) {
			std::stringstream ss;
			ss << get_name() << " is only allowed to run once! This is run " << run;
			fail(ss.str());
		}
		Module& module = graph.get_module();

		auto entry_point_name = this->entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		Function* old_entry_point = module.getFunction(StringRef(*entry_point_name));
		LLVMContext& context = module.getContext();
		FunctionType* fake_entry_ty = nullptr;
		if (old_entry_point == nullptr) {
			logger.warn() << "entry point " << *entry_point_name << " does not exist." << std::endl;
			fake_entry_ty = FunctionType::get(Type::getVoidTy(context), false);
		} else if (!(old_entry_point->getReturnType()->isVoidTy() || old_entry_point->getReturnType()->isIntegerTy())) {
			fail("Entry point must return void or int.");
		} else {
			fake_entry_ty = old_entry_point->getFunctionType();
			logger.debug() << "Old entry point: " << *entry_point_name << std::endl;
		}

		IRBuilder<> builder(context);
		// FunctionType* fty = FunctionType::get(Type::getVoidTy(context), false);
		Function* fake = Function::Create(fake_entry_ty, Function::ExternalLinkage, constants::ARA_ENTRY_POINT, module);
		BasicBlock* bb = BasicBlock::Create(context, "entry", fake);
		builder.SetInsertPoint(bb);

		logger.debug() << "colecting _GLOBAL__sub_I_* functions" << std::endl;
		for (Function& cur : module) {
			logger.debug() << "current func: " << cur.getName().str() << std::endl;
			if (cur.getName().str().rfind("_GLOBAL__sub_I_", 0) == 0) {
				logger.info() << "constructor found: " << cur.getName().str() << std::endl;
				builder.CreateCall(&cur, std::vector<Value*>());
			}
		}
		// Only call old entry if it exists, otherwise fake_entry_point just returns.
		if (old_entry_point == nullptr) {
			builder.CreateRetVoid();
		} else {
			std::vector<Value*> args;
			for (Argument& arg : fake->args()) {
				args.emplace_back(&arg);
			}

			if (old_entry_point->getReturnType()->isVoidTy()) {
				// It is not allowed to assign a name if return type is 'void'
				builder.CreateCall(old_entry_point, args);
				builder.CreateRetVoid();
			} else {
				CallInst* o_call = builder.CreateCall(old_entry_point, args, "old_entry");
				builder.CreateRet(o_call);
			}
		}
		logger.debug() << "new entry: " << *fake << std::endl;

		llvm::json::Value v(llvm::json::Object{{"entry_point", constants::ARA_ENTRY_POINT}});
		step_manager.change_global_config(v);
	}
} // namespace ara::step
