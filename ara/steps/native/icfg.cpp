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

			void link_unresolved_function_pointer(Vertex call_abb, Vertex after_call) {
				// first try: match all function signatures. This is slightly better that using all
				// functions as possible pointer target but of course not exact
				logger.info() << "Unresolved call to function pointer. ABB: " << cfg.name[call_abb] << std::endl;
				llvm::CallBase* called_func =
				    llvm::dyn_cast<llvm::CallBase>(&cfg.get_entry_bb<Graph>(call_abb)->front());
				assert(called_func != nullptr);
				const llvm::FunctionType* called_type = called_func->getFunctionType();

				for (llvm::Function& candidate : mod) {
					if (candidate.empty() || candidate.isIntrinsic()) {
						continue;
					}
					if (candidate.getFunctionType() == called_type) {
						auto callee = cfg.back_map<Graph>(graph, candidate);
						auto callee_abb = cfg.get_entry_abb(graph, callee);
						// ingoing edge
						add_icf_edge(call_abb, callee_abb, true);

						// outgoing edge
						Vertex back_abb;
						if (cfg.implemented[callee]) {
							auto lfunc = reinterpret_cast<llvm::Function*>(cfg.function[callee]);
							auto scc_it = llvm::scc_begin(lfunc);
							if (scc_it.hasLoop()) {
								logger.debug() << cfg.name[callee] << " ends in an endless loop." << std::endl;
								continue;
							}
							const llvm::BasicBlock* back_bb = *(*scc_it).begin();
							back_abb = cfg.back_map<Graph>(graph, *back_bb);
						} else {
							back_abb =
							    cfg.get_vertex(graph, callee, [&](Edge e) { return cfg.etype[e] == CFType::f2a; });
						}

						add_icf_edge(back_abb, after_call, false);
					}
				}
			}

		  public:
			ICFGImpl(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger, SVF::ICFG& icfg)
			    : graph(g), cfg(cfg), mod(mod), logger(logger), icfg(icfg) {
				for (auto call_abb : boost::make_iterator_range(
				         boost::vertices(cfg.filter_by_abb(g, graph::ABBType::call | graph::ABBType::syscall)))) {
					const auto after_call =
					    cfg.get_vertex(graph, call_abb, [&](Edge e) { return cfg.etype[e] == CFType::lcf; });

					if (!link_with_svf_icfg(call_abb, after_call)) {
						link_unresolved_function_pointer(call_abb, after_call);
					}
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
