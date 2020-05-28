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
		logger.info() << "Execute FakeEntryPoint step." << std::endl;

		const std::optional<std::string>& old_entry_point = entry_point.get();
		if (!old_entry_point) {
			logger.error() << "No entry point given" << std::endl;
			exit(1);
		}
		logger.info() << "old entry point: " << *old_entry_point << std::endl;

		Module& module = graph.get_module();
		LLVMContext& context = module.getContext();
		IRBuilder<> builder(context);
		FunctionType* fty = FunctionType::get(Type::getVoidTy(context), std::vector<Type*>(), false);
		Function* fake = Function::Create(fty, Function::ExternalLinkage, "__ara_fake_entry", module);
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
		builder.CreateCall(module.getFunction(StringRef(*old_entry_point)), std::vector<Value*>(), "old_entry");
		builder.CreateRetVoid();
		logger.debug() << "new entry: " << *fake << std::endl;
	}
} // namespace ara::step
