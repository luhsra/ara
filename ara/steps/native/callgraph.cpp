// SPDX-FileCopyrightText: 2020 Yannick Loeck
// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2022 Domenik Kuhn
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "callgraph.h"

#include "common/exceptions.h"
#include "common/util.h"

#include <Graphs/PTACallGraph.h>
#include <WPA/Andersen.h>
#include <boost/graph/filtered_graph.hpp>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <queue>
#include <type_traits>
#include <typeinfo>

namespace ara::step {
	std::string CallGraph::get_description() {
		return "Map the callgraph that is retrieved by SVF to the ARA datastructure";
	}

	namespace {
		template <class V>
		struct MakeClean {
			using type = typename std::make_signed<typename std::remove_reference<V>::type>::type;
		};

		template <class T, class U>
		constexpr bool check_graph_tool_compability() {
			return std::is_same<typename MakeClean<T>::type, typename MakeClean<U>::type>::value;
		}

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
			std::map<const SVF::PTACallGraphNode*, CallVertex> svf_to_ara_nodes;
			std::queue<CFVertex> unhandled_functions;
			unsigned node_counter, edge_counter;

			CFVertex get_function(const SVF::PTACallGraphNode& svf_node) {
				const llvm::Function* func = svf_node.getFunction()->getLLVMFun();
				return cfg.back_map(cfg_obj, safe_deref(func));
			}

			std::pair<CallVertex, bool> map_svf_call_node(const SVF::PTACallGraphNode& svf_node,
			                                              std::optional<CFVertex> func = std::nullopt) {
				CallVertex call_node;
				auto cand = svf_to_ara_nodes.find(&svf_node);
				if (cand != svf_to_ara_nodes.end()) {
					logger.debug() << "Call node already handled: " << svf_node << std::endl;
					return std::make_pair(cand->second, true);
				} else {
					CFVertex func_v = (func) ? *func : get_function(svf_node);
					if (boost::vertex(callgraph.function[boost::vertex(cfg.call_graph_link[func_v], callg_obj)],
					                  cfg_obj) == func_v) {
						// already handled in a previous callgraph step
						logger.debug() << "Call node already handled in a previous run: " << cfg.name[func_v]
						               << std::endl;
						return std::make_pair(boost::vertex(cfg.call_graph_link[func_v], callg_obj), false);
					} else {

						logger.debug() << "Add new node: " << svf_node << std::endl;
						call_node = boost::add_vertex(callg_obj);
						node_counter++;
						svf_to_ara_nodes.insert(std::make_pair(&svf_node, call_node));

						// properties
						unhandled_functions.push(func_v);
						static_assert(
						    check_graph_tool_compability<decltype(callgraph.function[call_node]), decltype(func_v)>(),
						    "The function vertex of the graph tool CFG can not be stored in CallGraph vertex property "
						    "due "
						    "to incompatible types");
						callgraph.function[call_node] = func_v;
						callgraph.function_name[call_node] = cfg.name[func_v];
						cfg.call_graph_link[func_v] = call_node;
						cfg.call_graph_link[func_v] = call_node;
						callgraph.svf_vlink[call_node] = reinterpret_cast<uintptr_t>(&svf_node);
						return std::make_pair(call_node, true);
					}
				}
			}

			void map_svf_call_edge(const SVF::PTACallGraphEdge& svf_edge) {
				const SVF::PTACallGraphNode& source = safe_deref(svf_edge.getSrcNode());
				const SVF::PTACallGraphNode& dst = safe_deref(svf_edge.getDstNode());

				// this function may add the vertices
				auto [s_vert, s_new] = map_svf_call_node(source);
				auto [d_vert, d_new] = map_svf_call_node(dst);

				if (!s_new && !d_new) {
					logger.debug() << "Skip edge. It already exists." << std::endl;
					return;
				}

				logger.debug() << "Edge: " << s_vert << " " << d_vert << std::endl;

				auto edge = boost::add_edge(s_vert, d_vert, callg_obj);
				edge_counter++;

				// properties
				const SVF::CallICFGNode* out_cbn = svf_callgraph.getCallSite(svf_edge.getCallSiteID());
				const llvm::BasicBlock* out_bb = safe_deref(out_cbn).getParent()->getLLVMBasicBlock();
				CFVertex bb = cfg.back_map(cfg_obj, safe_deref(out_bb));

				callgraph.callsite[edge.first] = bb;
				callgraph.callsite_name[edge.first] = cfg.name[bb];
				callgraph.svf_elink[edge.first] = reinterpret_cast<uintptr_t>(&svf_edge);

				logger.debug() << "Add a new edge: " << callgraph.function_name[s_vert] << " -> "
				               << callgraph.function_name[d_vert]
				               << " (Callsite: " << callgraph.callsite_name[edge.first] << std::endl;
			}

			void link_with_svf_callgraph(CFVertex function) {
				const llvm::Function* l_func = cfg.get_llvm_function<CFGraph>(function);
				assert(l_func != nullptr && "l_func is null.");
				const SVF::SVFFunction* svf_func = SVF::LLVMModuleSet::getLLVMModuleSet()->getSVFFunction(l_func);
				assert(svf_func != nullptr && "svf_func is null.");
				SVF::PTACallGraphNode* cg_node = svf_callgraph.getCallGraphNode(svf_func);
				assert(cg_node != nullptr && "cg_node is null.");
				map_svf_call_node(*cg_node, function);

				// add edges
				for (SVF::PTACallGraphNode::iterator out_it = cg_node->OutEdgeBegin(); out_it != cg_node->OutEdgeEnd();
				     ++out_it) {
					const SVF::PTACallGraphEdge* cg_edge = *out_it;
					map_svf_call_edge(safe_deref(cg_edge));
				}
			}

		  public:
			// TODO
			CallGraphImpl(CFGraph& cfg_obj, graph::CFG& cfg, CaGraph& callg_obj, graph::CallGraph& callgraph,
			              SVF::PTACallGraph& svf_callgraph, llvm::Module& mod, Logger& logger,
			              StepManager& step_manager, const std::string& entry_point)
			    : cfg_obj(cfg_obj), cfg(cfg), callg_obj(callg_obj), callgraph(callgraph), svf_callgraph(svf_callgraph),
			      mod(mod), logger(logger), node_counter(0), edge_counter(0) {
				CFVertex entry_func;

				// TODO, put this into the EntryPoint class. This is copied from ICFG
				try {
					entry_func = cfg.get_function_by_name(cfg_obj, entry_point);
				} catch (FunctionNotFound&) {
					std::stringstream ss;
					ss << "Bad entry point given: " << entry_point << ". Could not be found.";
					logger.err() << ss.str() << std::endl;
					throw StepError("CallGraph", ss.str());
				}

				std::set<CFVertex> handled_functions;
				unhandled_functions.push(entry_func);

				while (!unhandled_functions.empty()) {
					CFVertex current_function = unhandled_functions.front();
					unhandled_functions.pop();
					if (handled_functions.find(current_function) != handled_functions.end()) {
						continue;
					}
					logger.debug() << "Analyzing function: " << cfg.name[current_function] << std::endl;
					handled_functions.insert(current_function);
					link_with_svf_callgraph(current_function);
				}
				logger.info() << "Added " << node_counter << " vertices and " << edge_counter << " edges." << std::endl;
				if (node_counter != 0 || edge_counter != 0) {
					step_manager.chain_step("SystemRelevantFunctions");
				}
			}
		};

		template <typename CFGraph>
		void map_callgraph(CFGraph& cfg_obj, graph::CFG& cfg, graph::CallGraph& callgraph,
		                   SVF::PTACallGraph& svf_callgraph, llvm::Module& mod, Logger& logger,
		                   StepManager& step_manager, const std::string& entry_point) {
			graph_tool::gt_dispatch<>()(
			    [&](auto& g) {
				    CallGraphImpl(cfg_obj, cfg, g, callgraph, svf_callgraph, mod, logger, step_manager, entry_point);
			    },
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

	llvm::json::Array CallGraph::get_configured_dependencies() {
		const auto& entry_point_name = entry_point.get();
		assert(entry_point_name && "Entry point argument not given");
		return llvm::json::Array{
		    llvm::json::Object{{{"name", "ResolveFunctionPointer"}, {"entry_point", *entry_point_name}}}};
	}

	void CallGraph::run() {
		llvm::Module& mod = graph.get_module();
		graph::CFG cfg = graph.get_cfg();
		graph::CallGraph callgraph = graph.get_callgraph();
		SVF::PTACallGraph& svf_callgraph = get_svf_callgraph();

		auto entry_point_name = this->entry_point.get();
		assert(entry_point_name && "Entry point argument not given");

		logger.info() << "Analyzing entry point: '" << *entry_point_name << "'" << std::endl;

		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    map_callgraph(g, cfg, callgraph, svf_callgraph, mod, logger, step_manager, *entry_point_name);
		    },
		    graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string dot_file = *dump_prefix.get() + *entry_point_name;
			svf_callgraph.dump(dot_file + ".svf");
			llvm::json::Value printer_conf(llvm::json::Object{{"name", "Printer"},
			                                                  {"dot", dot_file + ".dot"},
			                                                  {"graph_name", "CallGraph"},
			                                                  {"subgraph", "callgraph"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
