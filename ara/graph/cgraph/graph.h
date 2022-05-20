#pragma once

#include "common/exceptions.h"
#include "graph_data.h"
#include "mix.h"
#include "os.h"

#include <Python.h>
#include <boost/graph/depth_first_search.hpp>
#include <boost/python.hpp>
#include <graph_tool.hh>
#include <iostream>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <memory>

namespace ara::graph {

	/* pointers are stored in the int64_t properties, so check they fit */
	static_assert(sizeof(int64_t) == sizeof(void*));

	struct CFG {
		graph_tool::GraphInterface& graph;
		/* see graph.py for python definitions */
		typename graph_tool::vprop_map_t<std::string>::type name;
		typename graph_tool::vprop_map_t<int>::type type;
		typename graph_tool::vprop_map_t<int>::type level;
		typename graph_tool::vprop_map_t<int64_t>::type llvm_link;
		typename graph_tool::vprop_map_t<int64_t>::type bcet;
		typename graph_tool::vprop_map_t<int64_t>::type wcet;
		typename graph_tool::vprop_map_t<int64_t>::type loop_bound;
		typename graph_tool::vprop_map_t<unsigned char>::type is_exit;
		typename graph_tool::vprop_map_t<unsigned char>::type is_exit_loop_head;
		typename graph_tool::vprop_map_t<unsigned char>::type part_of_loop;
		typename graph_tool::vprop_map_t<unsigned char>::type loop_head;
		typename graph_tool::vprop_map_t<std::vector<std::string>>::type files;
		typename graph_tool::vprop_map_t<std::vector<int32_t>>::type lines;
		typename graph_tool::vprop_map_t<unsigned char>::type implemented;
		typename graph_tool::vprop_map_t<unsigned char>::type sysfunc;
		typename graph_tool::vprop_map_t<boost::python::object>::type arguments;
		typename graph_tool::vprop_map_t<long>::type call_graph_link;

		typename graph_tool::eprop_map_t<int>::type etype;
		typename graph_tool::eprop_map_t<unsigned char>::type is_entry;

		CFG(graph_tool::GraphInterface& graph) : graph(graph){};

		/**
		 * Return a CFG from the corresponding Python graph.
		 */
		static CFG get(PyObject* py_cfg);
		static std::unique_ptr<CFG> get_ptr(PyObject* py_cfg);

		/**
		 * Get the type of the Node (as ABBType)
		 */
		template <class Graph>
		ABBType get_type(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			return static_cast<ABBType>(type[v]);
		}
		/**
		 * Set the type of the Node (as ABBType)
		 */
		template <class Graph>
		void set_type(typename boost::graph_traits<Graph>::vertex_descriptor v, ABBType ty) {
			type[v] = static_cast<int>(ty);
		}

		/**
		 * Get the level of the Node (as NodeLevel)
		 */
		template <class Graph>
		NodeLevel get_level(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			return static_cast<NodeLevel>(level[v]);
		}
		/**
		 * Set the level of the Node (as NodeLevel)
		 */
		template <class Graph>
		void set_level(typename boost::graph_traits<Graph>::vertex_descriptor v, NodeLevel lev) {
			lev[v] = static_cast<int>(lev);
		}

		/**
		 * Predicate object for boost::filtered_graph. Can filter vertices by their level.
		 *
		 * Example usage:
		 * LevelFilter<Graph> f(<level_mask>);
		 * boost::filter_graph<Graph, boost::keep_all, LevelFilter<Graph>> foo(g, boost::keep_all(), f);
		 */
		class LevelFilter {
		  public:
			LevelFilter() : level_filter(0), cfg(nullptr) {}
			LevelFilter(const unsigned level_filter, const CFG* cfg) : level_filter(level_filter), cfg(cfg) {}
			template <class Vertex>
			bool operator()(const Vertex& v) const {
				std::cout << "LEVEL: " << static_cast<NodeLevel>(cfg->level[v]) << std::endl;
				std::cout << cfg->level[v] << " " << level_filter << " " << (cfg->level[v] & level_filter) << std::endl;
				return (cfg->level[v] & level_filter) != 0;
			}

		  private:
			const unsigned level_filter;
			const CFG* cfg;
		};

		template <typename Graph>
		auto filter_by_level(Graph& g, const unsigned level_filter) const -> auto {
			return boost::filtered_graph<Graph, boost::keep_all, LevelFilter>(g, boost::keep_all(),
			                                                                  LevelFilter(level_filter, this));
		}

		template <typename Graph>
		auto filter_by_level(Graph& g, const NodeLevel level_filter) const -> auto {
			return filter_by_level(g, static_cast<unsigned>(level_filter));
		}

		/**
		 * return a graph that contains only the function nodes
		 */
		template <class Graph>
		auto get_functions(Graph& g) const -> auto {
			return filter_by_level(g, NodeLevel::function);
		}
		/**
		 * return a graph that contains only the abb nodes
		 */
		template <class Graph>
		auto get_abbs(Graph& g) const -> auto {
			return filter_by_level(g, NodeLevel::abb);
		}
		/**
		 * return a graph that contains only the abb nodes
		 */
		template <class Graph>
		auto get_bbs(Graph& g) const -> auto {
			return filter_by_level(g, NodeLevel::bb);
		}

		/**
		 * Predicate object for boost::filtered_graph. Can filter ABB by their types.
		 *
		 * Example usage:
		 * ABBTypeFilter<ABBGraph> f(<abb_type_mask>);
		 * boost::filter_graph<ABBGraph, boost::keep_all, ABBTypeFilter<ABBGraph>> foo(g, boost::keep_all(), f);
		 */
		class ABBTypeFilter {
		  public:
			ABBTypeFilter() : type_filter(0), cfg(nullptr) {}
			ABBTypeFilter(const unsigned type_filter, const CFG* cfg) : type_filter(type_filter), cfg(cfg) {}
			template <class Vertex>
			bool operator()(const Vertex& v) const {
				return (cfg->type[v] & type_filter) != 0;
			}

		  private:
			const unsigned type_filter;
			const CFG* cfg;
		};

		template <typename Graph>
		auto filter_by_abb(Graph& g, const unsigned type_filter) const -> auto {
			return boost::filtered_graph<Graph, boost::keep_all, ABBTypeFilter>(g, boost::keep_all(),
			                                                                    ABBTypeFilter(type_filter, this));
		}

		/**
		 * Return the llvm bb of the given BB.
		 */
		template <class Graph>
		llvm::BasicBlock* get_llvm_bb(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			assert(get_level<Graph>(v) == NodeLevel::bb);
			return reinterpret_cast<llvm::BasicBlock*>(llvm_link[v]);
		}

		/**
		 * Return the llvm function of the given function.
		 */
		template <class Graph>
		llvm::Function* get_llvm_function(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			assert(get_level<Graph>(v) == NodeLevel::function);
			return reinterpret_cast<llvm::Function*>(llvm_link[v]);
		}

		/**
		 * Return the name to the call that this BB calls.
		 *
		 * Only valid in call or syscall BBs, return "" otherwise.
		 */
		template <class Graph>
		std::string bb_get_callname(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			if (!(get_type(v) == ABBType::call || get_type(v) == ABBType::syscall)) {
				return "";
			}
			return llvm_bb_get_callname(safe_deref(get_llvm_bb(v)));
		}
		/**
		 * Return the name to the call that this ABB calls.
		 *
		 * Only valid in call or syscall ABBs, return "" otherwise.
		 */
		template <class Graph>
		std::string abb_get_callname(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			return bb_get_call(get_entry_bb(v));
		}

		/**
		 * Return, if the call in a call or syscall BB is an indirect call.
		 */
		template <class Graph>
		bool bb_is_indirect(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			if (!(get_type(v) == ABBType::call || get_type(v) == ABBType::syscall)) {
				return false;
			}
			return bb_is_indirect(safe_deref(get_llvm_bb(v)));
		}

		/**
		 * Return Function that belongs to func.
		 *
		 * Throws exception, if func cannot be mapped.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor back_map(const Graph& g,
		                                                                const llvm::Function& func) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (get_level<Graph>(v) == NodeLevel::function && get_llvm_function<Graph>(v) == &func) {
					return v;
				}
			}
			throw FunctionNotFound(func.getName().str());
		}

		/**
		 * Return BB that belongs to bb.
		 *
		 * Throws exception, if bb cannot be mapped.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor back_map(const Graph& g,
		                                                                const llvm::BasicBlock& bb) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (get_level<Graph>(v) == NodeLevel::bb && get_llvm_bb<Graph>(v) == &bb) {
					return v;
				}
			}
			throw VertexNotFound(bb.getName().str());
		}

		/**
		 * Return the function with a specific name.
		 *
		 * Throws exception, if func cannot be found.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor get_function_by_name(const Graph& g,
		                                                                            const std::string func_name) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (func_name == name[v]) {
					return v;
				}
			}
			throw FunctionNotFound(func_name);
		}

		/**
		 * Get a vertex with a specific condition.
		 * TODO: make a generator out of that, once we use C++20
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor
		get_vertex(const Graph& g, const typename boost::graph_traits<Graph>::vertex_descriptor source,
		           std::function<bool(const typename boost::graph_traits<Graph>::edge_descriptor e)> filt) const {
			for (auto cand : boost::make_iterator_range(boost::out_edges(source, g))) {
				if (filt(cand)) {
					return boost::target(cand, g);
				}
			}
			throw VertexNotFound("CFG.get_vertex");
		}

		/**
		 * Return the entry abb of a function.
		 *
		 * Throws exception, if entry cannot be found.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor
		get_entry_abb(const Graph& g, typename boost::graph_traits<Graph>::vertex_descriptor function) const {
			return get_vertex(g, function, [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
				return etype[e] == CFType::f2a && is_entry[e];
			});
		}

		/**
		 * Return the entry BB of an ABB.
		 *
		 * Throws exception, if entry cannot be found.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor
		get_entry_bb(const Graph& g, typename boost::graph_traits<Graph>::vertex_descriptor abb) const {
			return get_vertex(g, abb, [&](typename boost::graph_traits<Graph>::edge_descriptor e) {
				return etype[e] == CFType::a2b && is_entry[e];
			});
		}

		/**
		 * Get the function of an ABB or BB.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor
		get_function(const Graph& g, typename boost::graph_traits<Graph>::vertex_descriptor abb) const {
			CFType ty;
			if (this->level[abb] == NodeLevel::abb) {
				ty = CFType::f2a;
			} else if (this->level[abb] == NodeLevel::bb) {
				ty = CFType::f2b;
			} else {
				assert(false && "CFG.get_function, false Node type");
			}
			auto [begin, end] = boost::in_edges(abb, g);
			auto match = std::find_if(begin, end, [&](auto e) -> bool { return this->etype[e] == ty; });
			assert(match != end && "CFG.get_function");
			return boost::source(*match, g);
		}

		/**
		 * Get the ABB of an BB.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor
		get_abb(const Graph& g, typename boost::graph_traits<Graph>::vertex_descriptor bb) const {
			auto [begin, end] = boost::in_edges(bb, g);
			auto match = std::find_if(begin, end, [&](auto e) -> bool { return this->etype[e] == graph::CFType::a2b; });
			assert(match != end && "CFG.get_abb");
			return boost::source(*match, g);
		}

		/**
		 * Doing an action for all reachable ABBs
		 *
		 * @param g Graph
		 * @param entry_function Entry function where the search begins
		 * @param do_with_abb Function that is executed on each ABB. The function will be invoked with a Graph and CFG
		 * and the current ABB node.
		 */
		template <class Graph>
		void execute_on_reachable_abbs(
		    Graph& g, typename boost::graph_traits<Graph>::vertex_descriptor entry_function,
		    std::function<void(const Graph&, CFG&, typename boost::graph_traits<Graph>::vertex_descriptor)>
		        do_with_abb) {
			auto entry_abb = get_entry_abb(g, entry_function);
			NoExitNodes<Graph> filter(&g, this);
			boost::filtered_graph<Graph, NoExitNodes<Graph>> fg(g, filter);
			NoBacktrackVisitor<boost::filtered_graph<Graph, NoExitNodes<Graph>>, Graph> nbv(*this, do_with_abb, g);
			auto indexmap = boost::get(boost::vertex_index, g);
			auto colormap = boost::make_vector_property_map<boost::default_color_type>(indexmap);
			try {
				depth_first_search(fg, nbv, colormap, entry_abb);
			} catch (StopDFSException&) { /*we are expecting that*/
			}
		}

	  private:
		struct CFGUniqueEnabler;

		/**
		 * Filter CFG by ICFG edges, but filter out all edges that are back edges.
		 *
		 * Helper class for execute_on_reachable_abbs
		 */
		template <class InnerGraph>
		class NoExitNodes {
		  public:
			NoExitNodes() : g(nullptr), cfg(nullptr) {}
			NoExitNodes(const InnerGraph* g, const CFG* cfg) : g(g), cfg(cfg) {}
			template <typename Edge>
			bool operator()(const Edge& e) const {
				assert(g != nullptr && "Graph must not be null");
				assert(cfg != nullptr && "CFG must not be null");
				auto src = boost::source(e, *g);
				if (cfg->type[src] == ABBType::call || cfg->type[src] == ABBType::syscall) {
					return cfg->etype[e] == CFType::icf || cfg->etype[e] == CFType::lcf;
				}
				return cfg->etype[e] == CFType::icf && !cfg->is_exit[boost::source(e, *g)];
			}

		  private:
			const InnerGraph* g;
			const CFG* cfg;
		};

		/**
		 * Implementation of a counting DFS visitor. Stops as soon as the first unreachable vertex is reached.
		 */
		template <class FilteredGraph, class InnerGraph>
		class NoBacktrackVisitor : public boost::default_dfs_visitor {
			using Vertex = typename boost::graph_traits<FilteredGraph>::vertex_descriptor;

		  public:
			NoBacktrackVisitor(CFG& cfg, std::function<void(const InnerGraph&, CFG&, Vertex)> discover_func,
			                   InnerGraph& ig)
			    : counter(0), discover_func(discover_func), cfg(cfg), ig(ig) {}

			void discover_vertex(Vertex u, const FilteredGraph&) {
				++counter;
				discover_func(ig, cfg, boost::vertex(u, ig));
			}
			void finish_vertex(Vertex, const FilteredGraph&) {
				--counter;
				if (counter == 0) {
					throw StopDFSException();
				}
			}

		  private:
			unsigned int counter;
			std::function<void(const InnerGraph&, CFG&, Vertex)> discover_func;
			CFG& cfg;
			InnerGraph& ig;
		};

		const std::string llvm_bb_get_callname(const llvm::BasicBlock& bb) const;
		bool bb_is_indirect(const llvm::BasicBlock& bb) const;
		const llvm::CallBase* get_call_base(const llvm::BasicBlock& bb) const;
	};

	class Graph;

	struct CallGraph {
	  private:
		friend class Graph;
		CallGraph(graph_tool::GraphInterface& graph) : graph(graph){};

		struct CallGraphUniqueEnabler;

	  public:
		graph_tool::GraphInterface& graph;
		/* vertex properties */
		typename graph_tool::vprop_map_t<long>::type function;
		typename graph_tool::vprop_map_t<std::string>::type function_name;
		typename graph_tool::vprop_map_t<int64_t>::type svf_vlink;
		typename graph_tool::vprop_map_t<unsigned char>::type recursive;
		/* vertex properties that belong to syscall categories */
#define ARA_SYS_ACTION(Value) typename graph_tool::vprop_map_t<unsigned char>::type syscall_category_##Value;
#include "syscall_category.inc"
#undef ARA_SYS_ACTION

		/* edge properties */
		typename graph_tool::eprop_map_t<long>::type callsite;
		typename graph_tool::eprop_map_t<std::string>::type callsite_name;
		typename graph_tool::eprop_map_t<int64_t>::type svf_elink;

		typename graph_tool::gprop_map_t<PyObject*>::type cfg;

		/**
		 * Return a CallGraph from the corresponding Python graph.
		 */
		static CallGraph get(PyObject* py_callgraph);
		static std::unique_ptr<CallGraph> get_ptr(PyObject* py_callgraph);

		/**
		 * Return the corresponding SVF callgraph node to the given node.
		 */
		template <class Graph>
		const SVF::PTACallGraphNode* get_svf_vlink(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			return reinterpret_cast<const SVF::PTACallGraphNode*>(svf_vlink[v]);
		}

		/**
		 * Return the corresponding SVF callgraph edge to the given edge.
		 */
		template <class Graph>
		const SVF::PTACallGraphEdge* get_svf_elink(typename boost::graph_traits<Graph>::edge_descriptor v) const {
			return reinterpret_cast<const SVF::PTACallGraphEdge*>(svf_elink[v]);
		}

		/**
		 * Return edge that belongs to the appropriate Callgraph edge.
		 *
		 * Throws exception, if edge cannot be mapped.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::edge_descriptor back_map(const Graph g,
		                                                              const SVF::PTACallGraphEdge& edge) const {
			for (auto e : boost::make_iterator_range(boost::edges(g))) {
				if (get_svf_elink<Graph>(e) == &edge) {
					return e;
				}
			}
			throw EdgeNotFound("CallGraph.back_map");
		}
	};

	struct InstanceGraph {
	  private:
		friend class Graph;
		InstanceGraph(graph_tool::GraphInterface& graph) : graph(graph){};

		struct InstanceGraphUniqueEnabler;

	  public:
		graph_tool::GraphInterface& graph;
		/* vertex properties */
		typename graph_tool::vprop_map_t<std::string>::type label;
		typename graph_tool::vprop_map_t<boost::python::object>::type obj;
		typename graph_tool::vprop_map_t<std::string>::type id;
		typename graph_tool::vprop_map_t<unsigned char>::type branch;
		typename graph_tool::vprop_map_t<unsigned char>::type loop;
		typename graph_tool::vprop_map_t<unsigned char>::type recursive;
		typename graph_tool::vprop_map_t<unsigned char>::type after_scheduler;
		typename graph_tool::vprop_map_t<unsigned char>::type unique;
		typename graph_tool::vprop_map_t<long>::type soc;
		typename graph_tool::vprop_map_t<int64_t>::type llvm_soc;
		typename graph_tool::vprop_map_t<unsigned char>::type is_control;
		typename graph_tool::vprop_map_t<std::string>::type file;
		typename graph_tool::vprop_map_t<int>::type line;
		typename graph_tool::vprop_map_t<std::string>::type specialization_level;

		/* edge properties */
		typename graph_tool::eprop_map_t<std::string>::type elabel;
		typename graph_tool::eprop_map_t<int>::type type;
		typename graph_tool::eprop_map_t<int>::type syscall;

		/**
		 * Return a CallGraph from the corresponding Python graph.
		 */
		static InstanceGraph get(PyObject* py_instancegraph);
		static std::unique_ptr<InstanceGraph> get_ptr(PyObject* py_instancegraph);

		/**
		 * Return the corresponding LLVM SOC to the given node.
		 */
		template <class Graph>
		const llvm::Instruction* get_llvm_soc(typename boost::graph_traits<Graph>::vertex_descriptor v) const {
			return reinterpret_cast<const llvm::Instruction*>(llvm_soc[v]);
		}
	};

	/**
	 * C++ representation of the graph.
	 *
	 * It stores the Python graph and GraphData separately, although the Python graph contains the GraphData.
	 * This is for convenience since the actual extraction is done with Cython.
	 */
	class Graph {
	  private:
		// TODO: refcount this with boost
		PyObject* graph;
		GraphData* graph_data;

	  public:
		Graph() : graph(nullptr), graph_data(nullptr) {}
		Graph(PyObject* g, GraphData& graph_data) : graph(g), graph_data(&graph_data) {}

		/**
		 * convenience function to get the llvm module directly
		 */
		llvm::Module& get_module() { return safe_deref(graph_data).get_module(); }
		const llvm::Module& get_module() const { return safe_deref(graph_data).get_module(); }
		/**
		 * convenience function to get the svfg directly
		 */
		SVF::SVFG& get_svfg() { return safe_deref(graph_data).get_svfg(); }

		GraphData& get_graph_data() { return safe_deref(graph_data); }

		PyObject* get_pygraph() { return graph; }

		os::OS get_os();
		bool has_os_set();

		CFG get_cfg();
		std::unique_ptr<CFG> get_cfg_ptr();

		CallGraph get_callgraph();
		std::unique_ptr<CallGraph> get_callgraph_ptr();

		InstanceGraph get_instances();
		std::unique_ptr<InstanceGraph> get_instances_ptr();
	};
} // namespace ara::graph
