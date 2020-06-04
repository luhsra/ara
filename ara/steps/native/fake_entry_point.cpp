// vim: set noet ts=4 sw=4:

#include "fake_entry_point.h"

#include <llvm/IR/IRBuilder.h>
using namespace llvm;
namespace ara::step {

	std::string FakeEntryPoint::get_description() const {
		return "Create a fake entry point which calls all constructors before the real entry pouint is reached. "
		       "This is task of the startup code and needs to be simulated for correctness and instance detection. "
		       "";
	}

	void FakeEntryPoint::fill_options() { opts.emplace_back(entry_point); }

	void FakeEntryPoint::run(graph::Graph& graph) {
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
		if (old_entry_point == nullptr) {
			logger.warn() << "entry point " << *entry_point_name << " does not exist.";
		}
		if (!(old_entry_point->getReturnType()->isVoidTy() || old_entry_point->getReturnType()->isIntegerTy())) {
			fail("Entry point must return void or int.");
		}
		logger.debug() << "Old entry point: " << *entry_point_name << std::endl;

		LLVMContext& context = module.getContext();
		IRBuilder<> builder(context);
		// FunctionType* fty = FunctionType::get(Type::getVoidTy(context), false);
		Function* fake =
		    Function::Create(old_entry_point->getFunctionType(), Function::ExternalLinkage, "__ara_fake_entry", module);
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
		std::vector<Value*> args;
		for (Argument& arg : fake->args()) {
			args.emplace_back(&arg);
		}
		CallInst* o_call = builder.CreateCall(old_entry_point, args, "old_entry");
		if (old_entry_point->getReturnType()->isVoidTy()) {
			builder.CreateRetVoid();
		} else {
			builder.CreateRet(o_call);
		}
		logger.debug() << "new entry: " << *fake << std::endl;

		llvm::json::Value v(llvm::json::Object{{"entry_point", "__ara_fake_entry"}});
		step_manager.change_global_config(v);
	}
} // namespace ara::step
