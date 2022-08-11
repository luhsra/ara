#pragma once

#include "common/util.h"

#include <Graphs/SVFG.h>
#include <boost/bimap.hpp>
#include <llvm/IR/Function.h>
#include <llvm/IR/Module.h>
#include <memory>
#include <vector>

namespace ara::graph {

	class CallPath;

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
		 * Map required for SVFG::from_llvm_value()
		 */
		std::map<const llvm::Value*, std::vector<uint64_t>> value_to_svfg_node;
		uint64_t nullptr_node;
		uint64_t blackhole_node;

		/**
		 * Workaround for SVF classes where we need additional attributes.
		 * The tuple conists of the
		 * 1. the SVF Node (SVF::NodeID)
		 * 2. a list of offset into a compound type (std::vector<int64_t>)
		 * 3. a context/CallPath (represented as hash due to include loops, std::size_t)
		 */
		using ObjMap = boost::bimap<std::tuple<SVF::NodeID, std::vector<int64_t>, std::size_t>, uint64_t>;
		ObjMap obj_map;

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
