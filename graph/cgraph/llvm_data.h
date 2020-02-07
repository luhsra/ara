#pragma once

#include <llvm/IR/Function.h>
#include <llvm/IR/Module.h>
#include <memory>
#include <vector>

namespace ara::graph {

	namespace llvmext {
		struct Function {
			llvm::BasicBlock* exit_block = nullptr;
			std::vector<llvm::BasicBlock*> endless_loops;
		};

		struct BasicBlock {
			bool is_exit_block = false;
			bool is_loop_head = false;
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
		std::map<const llvm::Function*, llvmext::Function> functions;
		std::map<const llvm::BasicBlock*, llvmext::BasicBlock> basic_blocks;

		LLVMData() : module(nullptr) {}

		llvm::Module& get_module() { return *module; }

		llvm::LLVMContext& get_context() { return context; }

		void initialize_module(std::unique_ptr<llvm::Module> module) {
			assert(this->module == nullptr);
			this->module = std::move(module);
		}
	};

} // namespace ara::graph
