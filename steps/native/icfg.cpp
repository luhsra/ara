// vim: set noet ts=4 sw=4:

#include "icfg.h"

#include "common/llvm_common.h"

#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/SCCIterator.h>

using namespace ara::cfg;

namespace step {
	std::string ICFG::get_description() const {
		return "Search all inter-procedural edges."
		       "\n"
		       "Transforming of the ABB CFG to an ABB ICFG.";
	}

	void ICFG::add_icf_edge(ABBGraph::vertex_descriptor from, ABBGraph::vertex_descriptor to, ABBGraph& graph,
	                        std::string name) {
		auto edge = boost::add_edge(from, to, graph);
		graph[edge.first].type = CFType::icf;
		logger.debug() << "Add an " << name << " edge from " << graph[from] << " (" << from << ") to " << graph[to]
		               << " (" << to << ")." << std::endl;
	}

	void ICFG::run(graph::Graph& graph) {
		ABBGraph& abbs = graph.new_graph.abbs();

		ABBTypeFilter<ABBGraph> call_filter(ABBType::call | ABBType::syscall, &abbs);
		boost::filtered_graph<ABBGraph, boost::keep_all, ABBTypeFilter<ABBGraph>> calls(abbs, boost::keep_all(),
		                                                                                call_filter);

		ABBTypeFilter<ABBGraph> non_call_filter(~(ABBType::call | ABBType::syscall), &abbs);
		boost::filtered_graph<ABBGraph, boost::keep_all, ABBTypeFilter<ABBGraph>> non_calls(abbs, boost::keep_all(),
		                                                                                    non_call_filter);

		// add edges between functions
		for (auto abbi : boost::make_iterator_range(vertices(calls))) {
			const ara::cfg::ABB& abb = abbs[abbi];

			assert(boost::out_degree(abbi, abbs) == 1);
			const ABBGraph::vertex_descriptor after_call = *boost::adjacent_vertices(abbi, abbs).first;

			std::vector<std::reference_wrapper<const FunctionDescriptor>> called_functions;
			std::vector<ABBGraph::vertex_descriptor> called_abbs;

			if (abb.is_indirect()) {
				// first try: match all function signatures. This is slightly better that using all functions
				// as possible pointer target but of course not exact
				logger.info() << "Call to function pointer. ABB:" << abb << std::endl;
				llvm::Module& mod = graph.new_graph.get_module();
				std::unique_ptr<FakeCallBase> called_func = FakeCallBase::create(&abb.entry_bb->front());
				assert(called_func != nullptr);
				const llvm::FunctionType* called_type = called_func->getFunctionType();

				for (llvm::Function& candidate : mod) {
					if (candidate.getFunctionType() == called_type) {
						auto& other_func = abbs.back_map(&candidate);
						auto other_abb = other_func.local_to_global(*(boost::vertices(other_func).first));

						called_functions.push_back(other_func);
						called_abbs.push_back(other_abb);
					}
				}
			} else {
				const FunctionDescriptor& func = abbs.get_function_by_name(abb.get_call());
				auto other_abb = func.local_to_global(*(boost::vertices(func).first));

				called_functions.push_back(func);
				called_abbs.push_back(other_abb);
			}

			// add ingoing edges
			for (const auto other_abb : called_abbs) {
				add_icf_edge(abbi, other_abb, abbs, "ingoing");
			}

			// add outgoing edges
			for (const FunctionDescriptor& func : called_functions) {
				ABBGraph::vertex_descriptor back_abb;

				if (boost::get_property(func).implemented) {
					llvm::Function* lfunc = boost::get_property(func).func;
					auto scc_it = llvm::scc_begin(lfunc);
					if (scc_it.hasLoop()) {
						logger.debug() << boost::get_property(func) << " ends in an endless loop." << std::endl;
						continue;
					}
					const llvm::BasicBlock* back_bb = *(*scc_it).begin();
					back_abb = abbs.back_map(back_bb);
				} else {
					back_abb = func.local_to_global(*(boost::vertices(func).first));
				}

				add_icf_edge(back_abb, after_call, abbs, "outgoing");
			}
		}
		// add edges within the same function
		for (auto abbi : boost::make_iterator_range(vertices(non_calls))) {
			auto edge_its = out_edges(abbi, abbs);
			std::vector<ABBGraph::edge_descriptor> edges(edge_its.first, edge_its.second);
			for (auto edge : edges) {
				if (abbs[edge].type == CFType::lcf) {
					auto i_edge = boost::add_edge(abbi, boost::target(edge, abbs), abbs);
					abbs[i_edge.first].type = CFType::icf;
				}
			}
		}
	}
} // namespace step
