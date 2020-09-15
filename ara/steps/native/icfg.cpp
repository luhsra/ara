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

			bool link_with_svf_icfg(Vertex call_abb, Vertex after_call) {
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
							if (bb == nullptr) {
								llvm::Function* lfun = fun->getLLVMFun();
								assert(fun != nullptr);
								Vertex callee = cfg.back_map(graph, *lfun);
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

		  public:
			ICFGImpl(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger, SVF::ICFG& icfg)
			    : graph(g), cfg(cfg), mod(mod), logger(logger), icfg(icfg) {

				// we cannot change the graph while in the out_edge iterator, therefore capture all abbs and connect
				// them after that
				std::vector<Vertex> call_abbs;
				for (auto call_abb : boost::make_iterator_range(
				         boost::vertices(cfg.filter_by_abb(g, graph::ABBType::call | graph::ABBType::syscall)))) {
					call_abbs.emplace_back(call_abb);
				}
				for (auto call_abb : call_abbs) {
					const auto after_call =
					    cfg.get_vertex(graph, call_abb, [&](Edge e) { return cfg.etype[e] == CFType::lcf; });

					if (!link_with_svf_icfg(call_abb, after_call)) {
						logger.error() << "Error in linking " << cfg.name[call_abb] << std::endl;
						assert(false && "This should never happen. All indirect pointers are resolved in SVFAnalyses.");
					}
				}

				std::vector<std::pair<Vertex, Vertex>> to_be_connected;
				for (auto abb :
				     boost::make_iterator_range(boost::vertices(cfg.filter_by_abb(g, graph::ABBType::computation)))) {
					for (const auto& edge : boost::make_iterator_range(boost::out_edges(abb, g))) {
						if (cfg.etype[edge] == CFType::lcf) {
							to_be_connected.emplace_back(std::make_pair(abb, boost::target(edge, g)));
						}
					}
				}
				for (const auto& [source, target] : to_be_connected) {
					auto i_edge = boost::add_edge(source, target, g);
					assert(i_edge.second && "Edge creation failed");
					cfg.etype[i_edge.first] = CFType::icf;
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

		graph_tool::gt_dispatch<>()([&](auto& g) { ICFGImpl(g, cfg, mod, logger, icfg); },
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
