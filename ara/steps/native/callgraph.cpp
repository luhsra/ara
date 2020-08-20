
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
#include <Graphs/PTACallGraph.h>
#include <Graphs/PAG.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

using namespace ara::graph;

namespace ara::step {
	std::string Callgraph::get_description() {
		return "";
	}

	namespace {
		template <typename Graph>
		class CallgraphImpl {
		  private:
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			using Edge = typename boost::graph_traits<Graph>::edge_descriptor;

			Graph& graph;
            CFG& cfg;
			llvm::Module& mod;
			Logger& logger;
            SVF::PTACallGraph& callgraph;

			void add_call_edge(Vertex from, Vertex to/*, bool ingoing*/) {
				if (!boost::edge(from, to, graph).second) {
					logger.debug() << "edge from " << from << " to " << to << " does not exist yet." << std::endl;
					boost::add_edge(from, to, graph);
				}
				logger.debug() << "edge from " << from << " to " << to << " already exists." << std::endl;
                /*
				auto edge = boost::add_edge(from, to, graph);
				cfg.etype[edge.first] = CFType::icf;
				if (!ingoing) {
					cfg.is_exit[from] = true;
				}
				std::string name = (ingoing) ? "ingoing" : "outgoing";
				logger.debug() << "Add an " << name << " edge from " << cfg.name[from] << " (" << from << ") to "
				               << cfg.name[to] << " (" << to << ")." << std::endl;
                */
			}

			bool link_with_svf_callgraph(Vertex call_abb) {
                // is this necessary?
                llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[call_abb]);
                llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				llvm::Function* func = called_func->getCalledFunction();
				logger.debug() << "working on function " << (func ? called_func->getCalledFunction()->getName().str() : "no func") << std::endl;
                SVF::PAG* pag = SVF::PAG::getPAG();
                SVF::CallBlockNode* cbn = pag->getICFG()->getCallBlockNode(called_func);
                SVF::PTACallGraphNode* cgn = callgraph.getCallGraphNode(cbn->getCaller());
                for (auto outedge = cgn->OutEdgeBegin(); outedge != cgn->OutEdgeEnd(); outedge++) {
                    //SVF::PTACallGraphNode* dst = (*outedge)->getDstNode();
					//logger.debug() << "callsite id: " << (*outedge)->getCallSiteID() << std::endl;
                    const SVF::CallBlockNode* outcbn = callgraph.getCallSite((*outedge)->getCallSiteID());
                    //const llvm::BasicBlock* outbb = outcbn->getParent();
					//logger.debug() << "bb: " << outbb->getName().str() << std::endl;
					const SVF::SVFFunction* fun = outcbn->getFun();
					Vertex dst = cfg.back_map(graph, *(fun->getLLVMFun()));
					//Vertex dst = cfg.back_map(graph, *outbb);
					Vertex dst_abb = cfg.get_entry_abb(graph, dst);
                    add_call_edge(call_abb, dst_abb);
                }

                // TODO return something that makes sense
				return false;
			}

		  public:
            // TODO
			CallgraphImpl(Graph& g, CFG& cfg, llvm::Module& mod, Logger& logger, SVF::PTACallGraph& callgraph)
			    : graph(g), cfg(cfg), mod(mod), logger(logger), callgraph(callgraph) {
				for (auto call_abb : boost::make_iterator_range(
				         boost::vertices(cfg.filter_by_abb(g, graph::ABBType::call | graph::ABBType::syscall)))) {
                    link_with_svf_callgraph(call_abb);
                }
            }
        };
	} // namespace

	SVF::PTACallGraph& Callgraph::get_callgraph() {
		SVF::PAG* pag = SVF::PAG::getPAG();
        SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
        SVF::PTACallGraph* ptacallgraph = ander->getPTACallGraph();
        return *ptacallgraph;
	}

	void Callgraph::run() {
		llvm::Module& mod = graph.get_module();
		CFG cfg = graph.get_cfg();
		SVF::PTACallGraph& callgraph = get_callgraph();

		graph_tool::gt_dispatch<>()([&](auto& g) { CallgraphImpl(g, cfg, mod, logger, callgraph); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid;

			callgraph.dump(dot_file + ".svf");

			llvm::json::Value printer_conf(llvm::json::Object{
			    {"name", "Printer"}, {"dot", dot_file + ".dot"}, {"graph_name", "Callgraph"}, {"subgraph", "abbs"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
