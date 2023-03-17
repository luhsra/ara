// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>
#include <llvm/IR/Intrinsics.h>

namespace ara::step {
	class AutosarGeneratorIR : public ConfStep<AutosarGeneratorIR> {
	  private:
		using ConfStep<AutosarGeneratorIR>::ConfStep;

		const static inline option::TOption<option::Bool> rename_syscalls_template{
		    "rename_syscalls", "Rename System Calls for specialization",
		    /* ty = */ option::Bool(),
		    /* default = */ false};
		option::TOptEntity<option::Bool> rename_syscalls;
		virtual void init_options() override;

		void AddKickoffFunctionCalls(llvm::Module& module, llvm::LLVMContext& context);
		void RenameSystemcall(llvm::Module& module, llvm::CallInst* call);
		void RenameSystemcalls(llvm::Module& module);

	  public:
		virtual ~AutosarGeneratorIR(){};
		static std::string get_name() { return "AutosarGeneratorIR"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override { return {"IPIAvoidance", "LockElision"}; }

		virtual void run() override;
	};
} // namespace ara::step
