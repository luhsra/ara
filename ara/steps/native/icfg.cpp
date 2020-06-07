// vim: set noet ts=4 sw=4:

#include "icfg.h"

#include "common/exceptions.h"

#include <boost/graph/filtered_graph.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <queue>

using namespace ara::graph;
using namespace boost::property_tree;

namespace ara::step {
	std::string ICFG::get_description() const {
		return "Search all interprocedural edges."
		       "\n"
		       "Transforming of the ABB CFG to an ABB ICFG. The search is done from the entry point of the program. "
		       "Unused functions are not analyzed.";
	}

	void ICFG::fill_options() { opts.emplace_back(entry_point); }

	namespace {
		template <typename Graph>
		class ICFGImpl {
		  private:
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			using Edge = typename boost::graph_traits<Graph>::edge_descriptor;

			Graph& graph;
			CFG& cfg;
			llvm::Module& mod;
			Logger& logger;

			void add_icf_edge(Vertex from, Vertex to, bool ingoing) {
				auto edge = boost::add_edge(from, to, graph);
				cfg.etype[edge.first] = CFType::icf;
				if (!ingoing) {
					cfg.is_exit[from] = true;
				}
				std::string name = (ingoing) ? "ingoing" : "outgoing";
				logger.debug() << "Add an " << name << " edge from " << cfg.name[from] << " (" << from << ") to "
				               << cfg.name[to] << " (" << to << ")." << std::endl;
			}

			void link_call(Vertex call, std::queue<Vertex>& unhandled_functions) {
				const auto after_call =
				    cfg.get_vertex(graph, call, [&](Edge e) { return cfg.etype[e] == CFType::lcf; });

				std::vector<Vertex> called_functions;
				std::vector<Vertex> called_abbs;

				// find the called function
				if (cfg.abb_is_indirect<Graph>(call)) {
					// first try: match all function signatures. This is slightly better that using all
					// functions as possible pointer target but of course not exact
					logger.info() << "Call to function pointer. ABB: " << cfg.name[call] << std::endl;
					llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(
					    &reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[call])->front());
					assert(called_func != nullptr);
					const llvm::FunctionType* called_type = called_func->getFunctionType();

					for (llvm::Function& candidate : mod) {
						if (candidate.empty() || candidate.isIntrinsic()) {
							continue;
						}
						if (candidate.getFunctionType() == called_type) {
							auto other_func = cfg.back_map<Graph>(graph, candidate);
							auto other_entry = cfg.get_entry_abb(graph, other_func);
							called_functions.push_back(other_func);
							called_abbs.push_back(other_entry);
						}
					}
				} else {
					auto func = cfg.get_function_by_name(graph, cfg.abb_get_call<Graph>(call));
					auto other_entry = cfg.get_entry_abb(graph, func);

					called_functions.push_back(func);
					called_abbs.push_back(other_entry);
				}

				// add ingoing edges
				for (const auto other_abb : called_abbs) {
					add_icf_edge(call, other_abb, true);
				}

				// add outgoing edges
				for (auto func : called_functions) {
					assert(cfg.is_function[func]);
					unhandled_functions.push(func);

					Vertex back_abb;

					if (cfg.implemented[func]) {
						auto lfunc = reinterpret_cast<llvm::Function*>(cfg.function[func]);
						auto scc_it = llvm::scc_begin(lfunc);
						if (scc_it.hasLoop()) {
							logger.debug() << cfg.name[func] << " ends in an endless loop." << std::endl;
							continue;
						}
						const llvm::BasicBlock* back_bb = *(*scc_it).begin();
						back_abb = cfg.back_map<Graph>(graph, *back_bb);
					} else {
						back_abb = cfg.get_vertex(graph, func, [&](Edge e) { return cfg.etype[e] == CFType::f2a; });
					}

					add_icf_edge(back_abb, after_call, false);
				}
			}

			void link_abb(Vertex abb) {
				auto edge_its = out_edges(abb, graph);
				std::vector<typename boost::graph_traits<Graph>::edge_descriptor> edges(edge_its.first,
				                                                                        edge_its.second);
				for (auto edge : edges) {
					if (cfg.etype[edge] == CFType::lcf) {
						auto i_edge = boost::add_edge(abb, boost::target(edge, graph), graph);
						cfg.etype[i_edge.first] = CFType::icf;
					}
				}
			}

			void link_function(Vertex function, std::queue<Vertex>& unhandled_functions) {
				// if entry is already linked, a previous ICFG step has handled this function
				auto entry = cfg.get_entry_abb(graph, function);
				try {
					cfg.get_vertex(graph, entry, [&](Edge e) { return cfg.etype[e] == CFType::icf; });
					logger.debug() << "Function " << cfg.name[function] << " already analyzed." << std::endl;
					return;
				} catch (VertexNotFound&) {
				}
				for (auto o_edge : boost::make_iterator_range(boost::out_edges(function, graph))) {
					if (cfg.etype[o_edge] == CFType::f2a) {
						auto abb = boost::target(o_edge, graph);
						if (cfg.type[abb] == ABBType::call || cfg.type[abb] == ABBType::syscall) {
							// add edges between function
							link_call(abb, unhandled_functions);
						} else {
							// add edges within the same function
							link_abb(abb);
						}
					}
				}
			}

		  public:
			ICFGImpl(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger, std::string entry_point)
			    : graph(g), cfg(cfg), mod(mod), logger(logger) {
				Vertex entry_func;

				try {
					entry_func = cfg.get_function_by_name(graph, entry_point);
				} catch (FunctionNotFound&) {
					std::stringstream ss;
					ss << "Bad entry point given: " << entry_point << ". Could not be found.";
					logger.error() << ss.str();
					throw StepError("ICFG", ss.str());
				}

				std::set<Vertex> handled_functions;
				std::queue<Vertex> unhandled_functions;
				unhandled_functions.push(entry_func);

				while (!unhandled_functions.empty()) {
					Vertex current_function = unhandled_functions.front();
					unhandled_functions.pop();
					if (handled_functions.find(current_function) != handled_functions.end()) {
						continue;
					}

					handled_functions.insert(current_function);
					link_function(current_function, unhandled_functions);
				}
			}
		};

	} // namespace

	void ICFG::run(Graph& graph) {
		llvm::Module& mod = graph.get_module();
		CFG cfg = graph.get_cfg();

		auto entry_point_name = this->entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		graph_tool::gt_dispatch<>()([&](auto& g) { ICFGImpl(g, cfg, mod, logger, *entry_point_name); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid + ".dot";

			llvm::json::Value printer_conf(llvm::json::Object{
			    {"name", "Printer"}, {"dot", dot_file}, {"graph_name", "ICFG"}, {"subgraph", "abbs"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
