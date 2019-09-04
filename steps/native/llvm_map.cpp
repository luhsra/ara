// vim: set noet ts=4 sw=4:

#include "llvm_map.h"

#include "common/llvm_common.h"

#include <llvm/IR/BasicBlock.h>

using namespace llvm;
using namespace std;

namespace step {
	std::string LLVMMap::get_description() const {
		return "Map llvm::Basicblock and ara::cfg::ABB"
		       "\n"
		       "Maps in a one to one mapping.";
	}

	void LLVMMap::run(graph::Graph& graph) {
		ara::graph::Graph& new_graph = graph.new_graph;
		Module& mod = new_graph.get_module();
		ara::cfg::ABBGraph& abbs = new_graph.abbs();

		map<const BasicBlock*, std::shared_ptr<ara::cfg::ABB>> bb_map;

		unsigned name_counter = 0;

		for (Function& func : mod) {
			if (func.isIntrinsic()) {
				continue;
			}
			ara::cfg::FunctionDescriptor& function = abbs.create_subgraph();

			ara::cfg::Function& f = boost::get_property(function);
			f.name = func.getName();
			f.func = &func;
			f.implemented = true;

			logger.debug() << "Inserted new function " << f.name << "." << std::endl;

			unsigned bb_counter = 0;
			for (BasicBlock& bb : func) {
				std::stringstream ss;
				ss << "ABB" << name_counter++;
				ara::cfg::ABBType ty = ara::cfg::ABBType::computation;
				if (FakeCallBase::isa(bb.front()) && !isInlineAsm(&bb.front()) && !isCallToLLVMIntrinsic(&bb.front())) {
					ty = ara::cfg::ABBType::call;
				}
				auto global_vertex = abbs.add_vertex(ss.str(), ty, &bb, &bb, function);
				auto local_vertex = function.global_to_local(global_vertex);
				bb_counter++;

				// connect already mapped successors and predecessors
				for (const BasicBlock* succ_b : successors(&bb)) {
					if (abbs.contain(succ_b)) {
						boost::add_edge(local_vertex, function.global_to_local(abbs.back_map(succ_b)), function);
					}
				}
				for (const BasicBlock* pred_b : predecessors(&bb)) {
					if (abbs.contain(pred_b)) {
						boost::add_edge(function.global_to_local(abbs.back_map(pred_b)), local_vertex, function);
					}
				}
			}
			if (bb_counter == 0) {
				abbs.add_vertex("empty", ara::cfg::ABBType::not_implemented, nullptr, nullptr, function);
				f.implemented = false;
			}
		}

		logger.info() << "Mapped " << name_counter << " ABBs." << std::endl;
	}
} // namespace step
