// vim: set noet ts=4 sw=4:

#include "icfg.h"

#include "common/exceptions.h"

#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <queue>

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/ICFG.h>
#include <Graphs/PAG.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace ara::graph;

namespace ara::step {
	std::string ICFG::get_description() {
		return "Map interprocedural edges."
		       "\n"
		       "The actual analysis is done by SVF. This step transfer the information to the ARA CFG.";
	}

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
			SVF::ICFG& icfg;

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

			bool link_with_svf_icfg(Vertex call_abb, Vertex after_call, std::queue<Vertex>& unhandled_functions) {
				llvm::Instruction& call_instr = cfg.get_entry_bb<Graph>(call_abb)->front();
				SVF::CallBlockNode* cbn = icfg.getCallBlockNode(&call_instr);
				assert(cbn != nullptr);

				bool linked = false;
				for (SVF::CallBlockNode::iterator edge_it = cbn->OutEdgeBegin(); edge_it != cbn->OutEdgeEnd();
				     ++edge_it) {
					SVF::ICFGEdge* edge = (*edge_it);
					logger.debug() << "Handle CallBlockNode: " << *cbn << " with edge " << *edge << std::endl;
					if (edge->isCallCFGEdge()) {
						SVF::ICFGNode* dest_g = (*edge_it)->getDstNode();
						if (SVF::FunEntryBlockNode* dest = llvm::dyn_cast<SVF::FunEntryBlockNode>(dest_g)) {
							// ingoing edge
							Vertex callee_abb;
							const llvm::BasicBlock* bb = dest->getBB();
							const SVF::SVFFunction* fun = dest->getFun();
							assert(fun != nullptr);
							llvm::Function* lfun = fun->getLLVMFun();
							assert(fun != nullptr);
							Vertex callee = cfg.back_map(graph, *lfun);
							unhandled_functions.push(callee);
							if (bb == nullptr) {
								callee_abb = cfg.get_entry_abb(graph, callee);
							} else {
								callee_abb = cfg.back_map(graph, *bb);
							}

							add_icf_edge(call_abb, callee_abb, true);
							linked = true;

							// outgoing edge
							// TODO: detect endless loops
							SVF::FunExitBlockNode* exit = icfg.getFunExitBlockNode(fun);
							const llvm::BasicBlock* exit_bb = exit->getBB();
							if (exit_bb != nullptr) {
								Vertex exit_abb = cfg.back_map(graph, *exit_bb);
								add_icf_edge(exit_abb, after_call, false);
							} else {
								add_icf_edge(callee_abb, after_call, false);
							}
						} else {
							assert(false && "Destination ICFGNode is not a FunEntryBlockNode.");
						}
					}
				}
				return linked;
			}

			void link_abb(Vertex abb) {
				auto edge_its = out_edges(abb, graph);
				std::vector<Edge> edges(edge_its.first, edge_its.second);
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

				// we cannot change the graph while in the out_edge iterator, therefore capture all abbs and connect
				// them after that
				std::vector<Vertex> call_abbs;
				std::vector<Vertex> normal_abbs;
				for (auto o_edge : boost::make_iterator_range(boost::out_edges(function, graph))) {
					if (cfg.etype[o_edge] == CFType::f2a) {
						auto abb = boost::target(o_edge, graph);
						if (cfg.type[abb] == ABBType::call || cfg.type[abb] == ABBType::syscall) {
							// add edges between function with SVF
							call_abbs.emplace_back(abb);
						} else {
							// add edges within the same function
							normal_abbs.emplace_back(abb);
						}
					}
				}

				// inter function edges
				for (auto call_abb : call_abbs) {
					const auto after_call =
					    cfg.get_vertex(graph, call_abb, [&](Edge e) { return cfg.etype[e] == CFType::lcf; });

					if (!link_with_svf_icfg(call_abb, after_call, unhandled_functions)) {
						logger.error() << "Error in linking " << cfg.name[call_abb] << std::endl;
						assert(false && "This should never happen. All indirect pointers are resolved in SVFAnalyses.");
					}
				}

				// intra function edges
				for (auto abb : normal_abbs) {
					link_abb(abb);
				}
			}

		  public:
			ICFGImpl(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger, SVF::ICFG& icfg,
			         const std::string& entry_point)
			    : graph(g), cfg(cfg), mod(mod), logger(logger), icfg(icfg) {
				Vertex entry_func;

				try {
					entry_func = cfg.get_function_by_name(graph, entry_point);
				} catch (FunctionNotFound&) {
					std::stringstream ss;
					ss << "Bad entry point given: " << entry_point << ". Could not be found.";
					logger.err() << ss.str() << std::endl;
					throw StepError("ICFG", ss.str());
				}
				logger.debug() << "Analyzing function: " << entry_point << std::endl;

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

	SVF::ICFG& ICFG::get_icfg() {
		SVF::PAG* pag = SVF::PAG::getPAG();
		assert(pag != nullptr && "PAG is null.");
		SVF::ICFG* icfg_p = pag->getICFG();
		assert(icfg_p != nullptr && "ICFG is null.");
		return *icfg_p;
	}

	void ICFG::run() {
		llvm::Module& mod = graph.get_module();
		CFG cfg = graph.get_cfg();
		SVF::ICFG& icfg = get_icfg();

		auto entry_point_name = this->entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		logger.info() << "Analyzing entry point: '" << *entry_point_name << "'" << std::endl;

		graph_tool::gt_dispatch<>()([&](auto& g) { ICFGImpl(g, cfg, mod, logger, icfg, *entry_point_name); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid;

			icfg.dump(dot_file + ".svf");

			llvm::json::Value printer_conf(llvm::json::Object{
			    {"name", "Printer"}, {"dot", dot_file + ".dot"}, {"graph_name", "ICFG"}, {"subgraph", "abbs"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
