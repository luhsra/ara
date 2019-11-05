// vim: set noet ts=4 sw=4:

#include "icfg.h"

#include "common/exceptions.h"

#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/SCCIterator.h>

using namespace ara::graph;

namespace ara::step {
	std::string ICFG::get_description() const {
		return "Search all inter-procedural edges."
		       "\n"
		       "Transforming of the ABB CFG to an ABB ICFG.";
	}

	template <typename Graph>
	void add_icf_edge(typename boost::graph_traits<Graph>::vertex_descriptor from,
	                  typename boost::graph_traits<Graph>::vertex_descriptor to, Graph& graph, CFG& cfg,
	                  std::string name, Logger& logger) {
		auto edge = boost::add_edge(from, to, graph);
		cfg.etype[edge.first] = CFType::icf;
		logger.debug() << "Add an " << name << " edge from " << cfg.name[from] << " (" << from << ") to "
		               << cfg.name[to] << " (" << to << ")." << std::endl;
	}

	template <typename Graph>
	typename boost::graph_traits<Graph>::vertex_descriptor
	get_vertex(const Graph& g, const typename boost::graph_traits<Graph>::vertex_descriptor source,
	           std::function<bool(const typename boost::graph_traits<Graph>::edge_descriptor e)> filt) {
		for (auto cand : boost::make_iterator_range(boost::out_edges(source, g))) {
			if (filt(cand)) {
				return boost::target(cand, g);
			}
		}
		throw VertexNotFound();
	}

	template <typename Graph>
	void check_icf(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger) {

		ABBTypeFilter call_filter(ABBType::call | ABBType::syscall, &cfg);
		boost::filtered_graph<Graph, boost::keep_all, ABBTypeFilter> calls(g, boost::keep_all(), call_filter);

		ABBTypeFilter non_call_filter(~(ABBType::call | ABBType::syscall), &cfg);
		boost::filtered_graph<Graph, boost::keep_all, ABBTypeFilter> non_calls(g, boost::keep_all(), non_call_filter);

		// add edges between functions
		for (auto abb : boost::make_iterator_range(boost::vertices(calls))) {
			const auto after_call =
			    get_vertex<Graph>(g, abb, [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
				    return cfg.etype[e] == CFType::lcf;
			    });

			std::vector<typename boost::graph_traits<Graph>::vertex_descriptor> called_functions;
			std::vector<typename boost::graph_traits<Graph>::vertex_descriptor> called_abbs;

			if (cfg.abb_is_indirect<Graph>(abb)) {
				// first try: match all function signatures. This is slightly better that using all functions
				// as possible pointer target but of course not exact
				logger.info() << "Call to function pointer. ABB: " << cfg.name[abb] << std::endl;
				llvm::CallBase* called_func =
				    llvm::dyn_cast<llvm::CallBase>(&reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb])->front());
				assert(called_func != nullptr);
				const llvm::FunctionType* called_type = called_func->getFunctionType();

				for (llvm::Function& candidate : mod) {
					if (candidate.getFunctionType() == called_type) {
						auto other_func = cfg.back_map<Graph>(g, candidate);
						auto other_abb = get_vertex<Graph>(g, other_func,
						                                   [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
							                                   return cfg.etype[e] == CFType::f2a && cfg.is_entry[e];
						                                   });

						called_functions.push_back(other_func);
						called_abbs.push_back(other_abb);
					}
				}
			} else {
				auto func = cfg.get_function_by_name(g, cfg.abb_get_call<Graph>(abb));
				auto other_abb =
				    get_vertex<Graph>(g, func, [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
					    return cfg.etype[e] == CFType::f2a && cfg.is_entry[e];
				    });

				called_functions.push_back(func);
				called_abbs.push_back(other_abb);
			}

			// add ingoing edges
			for (const auto other_abb : called_abbs) {
				add_icf_edge(abb, other_abb, g, cfg, "ingoing", logger);
			}

			// add outgoing edges
			for (auto func : called_functions) {
				typename boost::graph_traits<Graph>::vertex_descriptor back_abb;

				if (cfg.implemented[func]) {
					auto lfunc = reinterpret_cast<llvm::Function*>(cfg.function[func]);
					auto scc_it = llvm::scc_begin(lfunc);
					if (scc_it.hasLoop()) {
						logger.debug() << cfg.name[func] << " ends in an endless loop." << std::endl;
						continue;
					}
					const llvm::BasicBlock* back_bb = *(*scc_it).begin();
					back_abb = cfg.back_map<Graph>(g, *back_bb);
				} else {
					back_abb = get_vertex<Graph>(g, func, [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
						return cfg.etype[e] == CFType::f2a;
					});
				}

				add_icf_edge(back_abb, after_call, g, cfg, "outgoing", logger);
			}
		}
		// add edges within the same function
		for (auto abbi : boost::make_iterator_range(vertices(non_calls))) {
			auto edge_its = out_edges(abbi, g);
			std::vector<typename boost::graph_traits<Graph>::edge_descriptor> edges(edge_its.first, edge_its.second);
			for (auto edge : edges) {
				if (cfg.etype[edge] == CFType::lcf) {
					auto i_edge = boost::add_edge(abbi, boost::target(edge, g), g);
					cfg.etype[i_edge.first] = CFType::icf;
				}
			}
		}
	}

	void ICFG::run(Graph& graph) {
		llvm::Module& mod = graph.get_module();
		CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { check_icf(g, cfg, mod, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());
	}
} // namespace ara::step
