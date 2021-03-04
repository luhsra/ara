#pragma once

#include "common/util.h"

#include <Graphs/SVFG.h>
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
			bool is_exit_loop_head = false;
			bool is_part_of_loop = false;
		};
	} // namespace llvmext

	/**
	 * Class to encapsulate all C++ data structures that are not elsewhere mapped.
	 */
	class GraphData {
	  private:
		llvm::LLVMContext context;
		std::unique_ptr<llvm::Module> module;
		std::unique_ptr<SVF::SVFG> svfg;

	  public:
		/**
		 * Workaround for LLVM classes where we need additional attributes.
		 * We cannot inherit this classes, since LLVM type deduction needs global knowledge. Therefore we have a map
		 * here that extends LLVM.
		 */
		std::map<const llvm::Function*, llvmext::Function> functions;
		std::map<const llvm::BasicBlock*, llvmext::BasicBlock> basic_blocks;
		/**
		 * Workaround for SVF classes where we need additional attributes.
		 */
		std::map<SVF::NodeID, unsigned> obj_map;

		GraphData() : module(nullptr), svfg(nullptr) {}

		llvm::LLVMContext& get_context() { return context; }

		llvm::Module& get_module() { return safe_deref(module); }

		void initialize_module(std::unique_ptr<llvm::Module> module) {
			assert(this->module == nullptr && "module already initialized");
			this->module = std::move(module);
		}

		SVF::SVFG& get_svfg() { return safe_deref(svfg); }

		void initialize_svfg(std::unique_ptr<SVF::SVFG> svfg) {
			assert(this->svfg == nullptr && "module already initialized");
			this->svfg = std::move(svfg);
		}
	};

} // namespace ara::graph
