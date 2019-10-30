// vim: set noet ts=4 sw=4:

#include "llvm_map.h"

#include <llvm/IR/BasicBlock.h>

using namespace llvm;
using namespace std;

namespace step {

	template <typename Graph>
	typename boost::graph_traits<Graph>::vertex_descriptor
	add_abb(Graph& g, ara::graph::CFG& cfg, std::string name, ara::graph::ABBType type, const BasicBlock* entry,
	        const BasicBlock* exit, typename boost::graph_traits<Graph>::vertex_descriptor function, bool is_entry) {
		auto abb = boost::add_vertex(g);
		cfg.name[abb] = name;
		cfg.type[abb] = type;
		cfg.entry_bb[abb] = reinterpret_cast<intptr_t>(entry);
		cfg.exit_bb[abb] = reinterpret_cast<intptr_t>(exit);

		auto i_edge = boost::add_edge(abb, function, g);
		cfg.etype[i_edge.first] = ara::graph::CFType::a2f;

		auto o_edge = boost::add_edge(function, abb, g);
		cfg.etype[o_edge.first] = ara::graph::CFType::f2a;

		cfg.is_entry[o_edge.first] = is_entry;

		return abb;
	}

	template <typename Graph>
	void map_cfg(Graph& g, ara::graph::CFG& cfg, Module& mod, Logger& logger) {
		std::map<const BasicBlock*, typename boost::graph_traits<Graph>::vertex_descriptor> abbs;

		unsigned name_counter = 0;

		for (Function& func : mod) {
			if (func.isIntrinsic()) {
				continue;
			}
			auto function = boost::add_vertex(g);
			cfg.name[function] = func.getName();
			cfg.implemented[function] = true;
			cfg.function[function] = reinterpret_cast<intptr_t>(&func);
			cfg.is_function[function] = true;

			logger.debug() << "Inserted new function " << cfg.name[function] << "." << std::endl;

			unsigned bb_counter = 0;
			for (BasicBlock& bb : func) {
				std::stringstream ss;
				ss << "ABB" << name_counter++;
				ara::graph::ABBType ty = ara::graph::ABBType::computation;
				if (isa<CallBase>(bb.front()) && !isInlineAsm(&bb.front()) && !isCallToLLVMIntrinsic(&bb.front())) {
					ty = ara::graph::ABBType::call;
				}
				auto abb = add_abb(g, cfg, ss.str(), ty, &bb, &bb, function, bb_counter == 0);
				abbs[&bb] = abb;

				bb_counter++;

				// connect already mapped successors and predecessors
				for (const BasicBlock* succ_b : successors(&bb)) {
					if (abbs.find(succ_b) != abbs.end()) {
						auto edge = boost::add_edge(abb, abbs[succ_b], g);
						cfg.etype[edge.first] = ara::graph::CFType::lcf;
					}
				}
				for (const BasicBlock* pred_b : predecessors(&bb)) {
					if (abbs.find(pred_b) != abbs.end()) {
						auto edge = boost::add_edge(abbs[pred_b], abb, g);
						cfg.etype[edge.first] = ara::graph::CFType::lcf;
					}
				}
			}
			if (bb_counter == 0) {
				add_abb(g, cfg, "empty", ara::graph::ABBType::not_implemented, nullptr, nullptr, function, true);
				cfg.implemented[function] = false;
			}
		}

		logger.info() << "Mapped " << name_counter << " ABBs." << std::endl;
	}

	std::string LLVMMap::get_description() const {
		return "Map llvm::Basicblock and ara::graph::ABB"
		       "\n"
		       "Maps in a one to one mapping.";
	}

	void LLVMMap::run(ara::graph::Graph& graph) {
		Module& mod = graph.get_module();
		ara::graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { map_cfg(g, cfg, mod, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace step
