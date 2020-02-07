#pragma once

#include <llvm/IR/Function.h>
#include <llvm/IR/Module.h>
#include <memory>
#include <vector>

namespace ara::graph {

	namespace llvmext {
		struct Function {
			llvm::BasicBlock* exit_block;
			std::vector<llvm::BasicBlock*> endless_loops;
		};
	} // namespace llvmext

	/**
	 * Class to encapsulate all LLVM data structures needed for accessing LLVM objects.
	 */
	class LLVMData {
	  private:
		llvm::LLVMContext context;
		std::unique_ptr<llvm::Module> module;

	  public:
		/**
		 * Workaround for function specific additional attributes, since we cannot inherit the function class.
		 */
		std::map<llvm::Function*, llvmext::Function> functions;

		LLVMData() : module(nullptr) {}

		llvm::Module& get_module() { return *module; }

		llvm::LLVMContext& get_context() { return context; }

		void initialize_module(std::unique_ptr<llvm::Module> module) {
			assert(this->module == nullptr);
			this->module = std::move(module);
		}
	};

} // namespace ara::graph
