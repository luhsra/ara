#include "callgraph.h"

#include "common/exceptions.h"

#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <queue>

#define VERSION_BKP VERSION
#undef VERSION
#include <Graphs/PAG.h>
#include <Graphs/PTACallGraph.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

namespace ara::step {
	std::string CallGraph::get_description() {
		return "Map the callgraph that is retrieved by SVF to the ARA datastructure";
	}

	namespace {
		template <typename CFGraph, typename CaGraph>
		class CallGraphImpl {
		  private:
			using CFVertex = typename boost::graph_traits<CFGraph>::vertex_descriptor;
			using CFEdge = typename boost::graph_traits<CFGraph>::edge_descriptor;
			using CallVertex = typename boost::graph_traits<CaGraph>::vertex_descriptor;
			using CallEdge = typename boost::graph_traits<CaGraph>::edge_descriptor;

			CFGraph& cfg_obj;
			graph::CFG& cfg;
			CaGraph& callg_obj;
			graph::CallGraph& callgraph;
			SVF::PTACallGraph& svf_callgraph;
			llvm::Module& mod;
			Logger& logger;

			// void add_call_edge(Vertex from, Vertex to/*, bool ingoing*/) {
			// 	if (!boost::edge(from, to, graph).second) {
			// 		logger.debug() << "edge from " << from << " to " << to << " does not exist yet." << std::endl;
			// 		boost::add_edge(from, to, graph);
			// 	}
			// 	logger.debug() << "edge from " << from << " to " << to << " already exists." << std::endl;
			//     /*
			// 	auto edge = boost::add_edge(from, to, graph);
			// 	cfg.etype[edge.first] = CFType::icf;
			// 	if (!ingoing) {
			// 		cfg.is_exit[from] = true;
			// 	}
			// 	std::string name = (ingoing) ? "ingoing" : "outgoing";
			// 	logger.debug() << "Add an " << name << " edge from " << cfg.name[from] << " (" << from << ") to "
			// 	               << cfg.name[to] << " (" << to << ")." << std::endl;
			//     */
			// }

			void link_with_svf_callgraph(CFVertex function) {
				// // is this necessary?
				// llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[call_abb]);
				// llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				// llvm::Function* func = called_func->getCalledFunction();
				// logger.debug() << "working on function " << (func ? called_func->getCalledFunction()->getName().str()
				// : "no func") << std::endl; SVF::PAG* pag = SVF::PAG::getPAG(); SVF::CallBlockNode* cbn =
				// pag->getICFG()->getCallBlockNode(called_func); SVF::PTACallGraphNode* cgn =
				// callgraph.getCallGraphNode(cbn->getCaller()); for (auto outedge = cgn->OutEdgeBegin(); outedge !=
				// cgn->OutEdgeEnd(); outedge++) {
				//     //SVF::PTACallGraphNode* dst = (*outedge)->getDstNode();
				// 	//logger.debug() << "callsite id: " << (*outedge)->getCallSiteID() << std::endl;
				//     const SVF::CallBlockNode* outcbn = callgraph.getCallSite((*outedge)->getCallSiteID());
				//     //const llvm::BasicBlock* outbb = outcbn->getParent();
				// 	//logger.debug() << "bb: " << outbb->getName().str() << std::endl;
				// 	const SVF::SVFFunction* fun = outcbn->getFun();
				// 	Vertex dst = cfg.back_map(graph, *(fun->getLLVMFun()));
				// 	//Vertex dst = cfg.back_map(graph, *outbb);
				// 	Vertex dst_abb = cfg.get_entry_abb(graph, dst);
				//     add_call_edge(call_abb, dst_abb);
				// }

				// // TODO return something that makes sense
				// return false;
			}

		  public:
			// TODO
			CallGraphImpl(CFGraph& cfg_obj, graph::CFG& cfg, CaGraph& callg_obj, graph::CallGraph& callgraph,
			              SVF::PTACallGraph& svf_callgraph, llvm::Module& mod, Logger& logger)
			    : cfg_obj(cfg_obj), cfg(cfg), callg_obj(callg_obj), callgraph(callgraph), svf_callgraph(svf_callgraph),
			      mod(mod), logger(logger) {
				for (auto function : boost::make_iterator_range(boost::vertices(cfg.get_functions(cfg_obj)))) {
					link_with_svf_callgraph(function);
				}
			}
		};

		template <typename CFGraph>
		void map_callgraph(CFGraph& cfg_obj, graph::CFG& cfg, graph::CallGraph& callgraph,
		                   SVF::PTACallGraph& svf_callgraph, llvm::Module& mod, Logger& logger) {
			graph_tool::gt_dispatch<>()(
			    [&](auto& g) { CallGraphImpl(cfg_obj, cfg, g, callgraph, svf_callgraph, mod, logger); },
			    graph_tool::always_directed())(callgraph.graph.get_graph_view());
		}
	} // namespace

	SVF::PTACallGraph& CallGraph::get_svf_callgraph() {
		SVF::PAG* pag = SVF::PAG::getPAG();
		// this is actually a singleton, so the creation was done in SVFAnalyses
		SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
		SVF::PTACallGraph* ptacallgraph = ander->getPTACallGraph();
		return *ptacallgraph;
	}

	void CallGraph::run() {
		llvm::Module& mod = graph.get_module();
		graph::CFG cfg = graph.get_cfg();
		graph::CallGraph callgraph = graph.get_callgraph();
		SVF::PTACallGraph& svf_callgraph = get_svf_callgraph();

		graph_tool::gt_dispatch<>()([&](auto& g) { map_callgraph(g, cfg, callgraph, svf_callgraph, mod, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid;

			svf_callgraph.dump(dot_file + ".svf");

			llvm::json::Value printer_conf(llvm::json::Object{{"name", "Printer"},
			                                                  {"dot", dot_file + ".dot"},
			                                                  {"graph_name", "CallGraph"},
			                                                  {"subgraph", "callgraph"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
