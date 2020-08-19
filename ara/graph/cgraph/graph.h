#pragma once

#include "../mix.py"
#include "common/exceptions.h"
#include "llvm_data.h"

#include <Python.h>
#include <boost/graph/depth_first_search.hpp>
#include <boost/python.hpp>
#include <graph_tool.hh>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Module.h>
#include <memory>

namespace ara::graph {

	std::ostream& operator<<(std::ostream&, const ABBType&);
	std::ostream& operator<<(std::ostream&, const CFType&);

	/* pointers are stored in the int64_t properties, so check they fit */
	static_assert(sizeof(int64_t) == sizeof(void*));

	struct CFG {
		graph_tool::GraphInterface& graph;
		/* see graph.py for python definitions */
		typename graph_tool::vprop_map_t<std::string>::type name;
		typename graph_tool::vprop_map_t<int>::type type;
		typename graph_tool::vprop_map_t<unsigned char>::type is_function;
		typename graph_tool::vprop_map_t<int64_t>::type entry_bb;
		typename graph_tool::vprop_map_t<int64_t>::type exit_bb;
		typename graph_tool::vprop_map_t<unsigned char>::type is_exit;
		typename graph_tool::vprop_map_t<unsigned char>::type is_loop_head;
		typename graph_tool::vprop_map_t<unsigned char>::type implemented;
		typename graph_tool::vprop_map_t<unsigned char>::type syscall;
		typename graph_tool::vprop_map_t<int64_t>::type function;
		typename graph_tool::vprop_map_t<boost::python::object>::type arguments;

		typename graph_tool::eprop_map_t<int>::type etype;
		typename graph_tool::eprop_map_t<unsigned char>::type is_entry;

		CFG(graph_tool::GraphInterface& graph) : graph(graph){};

		class FunctionFilter {
		  public:
			FunctionFilter() : cfg(nullptr), reverted(false) {}
			FunctionFilter(const CFG* cfg, bool reverted = false) : cfg(cfg), reverted(reverted) {}
			template <class Vertex>
			bool operator()(const Vertex& v) const {
				return cfg->is_function[v] != reverted;
			}

		  private:
			const CFG* cfg;
			const bool reverted;
		};

		/**
		 * return a graph that contains only the function nodes
		 */
		template <class Graph>
		auto get_functions(Graph& g) const -> auto {
			FunctionFilter func(this);
			return boost::filtered_graph<Graph, boost::keep_all, FunctionFilter>(g, boost::keep_all(), std::move(func));
		}
		/**
		 * return a graph that contains only the abb nodes
		 */
		template <class Graph>
		auto get_abbs(Graph& g) const -> auto {
			FunctionFilter func(this, /* reverted= */ true);
			return boost::filtered_graph<Graph, boost::keep_all, FunctionFilter>(g, boost::keep_all(), std::move(func));
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
		 * Return the entry bb of the given ABB.
		 */
		template <class Graph>
		llvm::BasicBlock* get_entry_bb(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			return reinterpret_cast<llvm::BasicBlock*>(entry_bb[v]);
		}

		/**
		 * Return the exit bb of the given ABB.
		 */
		template <class Graph>
		llvm::BasicBlock* get_exit_bb(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			return reinterpret_cast<llvm::BasicBlock*>(exit_bb[v]);
		}

		/**
		 * Return the name to the call that this ABB calls.
		 *
		 * Only valid in call or syscall ABBs, return "" otherwise.
		 */
		template <class Graph>
		std::string abb_get_call(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			return bb_get_call(static_cast<ABBType>(type[v]), *(reinterpret_cast<llvm::BasicBlock*>(entry_bb[v])));
		}

		/**
		 * Return, if the call in a call or syscall ABB is an indirect call.
		 */
		template <class Graph>
		bool abb_is_indirect(typename boost::graph_traits<Graph>::vertex_descriptor v) {
			return bb_is_indirect(static_cast<ABBType>(type[v]), *(reinterpret_cast<llvm::BasicBlock*>(entry_bb[v])));
		}

		/**
		 * Return Function that belongs to func.
		 *
		 * Throws exception, if func cannot be mapped.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor back_map(const Graph g,
		                                                                const llvm::Function& func) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (reinterpret_cast<llvm::Function*>(function[v]) == &func) {
					return v;
				}
			}
			throw FunctionNotFound();
		}

		/**
		 * Return ABB that belongs to bb.
		 *
		 * Throws exception, if bb cannot be mapped.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor back_map(const Graph g,
		                                                                const llvm::BasicBlock& bb) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (reinterpret_cast<llvm::BasicBlock*>(entry_bb[v]) == &bb ||
				    reinterpret_cast<llvm::BasicBlock*>(exit_bb[v]) == &bb) {
					return v;
				}
			}
			throw VertexNotFound();
		}

		/**
		 * Return the function with a specific name.
		 *
		 * Throws exception, if func cannot be found.
		 */
		template <class Graph>
		typename boost::graph_traits<Graph>::vertex_descriptor get_function_by_name(const Graph g,
		                                                                            const std::string func_name) const {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				if (func_name == name[v]) {
					return v;
				}
			}
			throw FunctionNotFound();
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
			throw VertexNotFound();
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
			NoBacktrackVisitor<Graph> nbv(*this, do_with_abb);
			auto indexmap = boost::get(boost::vertex_index, g);
			auto colormap = boost::make_vector_property_map<boost::default_color_type>(indexmap);
			try {
				depth_first_search(g, nbv, colormap, entry_abb);
			} catch (StopDFSException&) { /*we are expecting that*/
			}
		}

	  private:
		/**
		 * Filter all edges that are back edges for the ICFG.
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
				return cfg->etype[e] == CFType::icf && !cfg->is_exit[boost::source(boost::edge(e), *g)];
			}

		  private:
			const InnerGraph* g;
			const CFG* cfg;
		};

		/**
		 * Implementation of a counting DFS visitor. Stops as soon as the first unreachable vertex is reached.
		 */
		template <class InnerGraph>
		class NoBacktrackVisitor : public boost::default_dfs_visitor {
			using Vertex = typename boost::graph_traits<InnerGraph>::vertex_descriptor;

		  public:
			NoBacktrackVisitor(CFG& cfg, std::function<void(const InnerGraph&, CFG&, Vertex)> discover_func)
			    : counter(0), discover_func(discover_func), cfg(cfg) {}

			void discover_vertex(Vertex u, const InnerGraph& g) {
				++counter;
				discover_func(g, cfg, u);
			}
			void finish_vertex(Vertex, const InnerGraph&) {
				--counter;
				if (counter == 0) {
					throw StopDFSException();
				}
			}

		  private:
			unsigned int counter;
			std::function<void(const InnerGraph&, CFG&, Vertex)> discover_func;
			CFG& cfg;
		};

		const std::string bb_get_call(const ABBType type, const llvm::BasicBlock& bb) const;
		bool bb_is_indirect(const ABBType type, const llvm::BasicBlock& bb) const;
		const llvm::CallBase* get_call_base(const ABBType type, const llvm::BasicBlock& bb) const;
	};

    struct Callgraph {
        graph_tool::GraphInterface& graph;
        /* vertex properties */
        typename graph_tool::vprop_map_t<std::string>::type label;
        typename graph_tool::vprop_map_t<std::string>::type func;
        //typename graph_tool::vprop_map_t<long>::type cfglink;
        typename graph_tool::vprop_map_t<int64_t>::type callgraphvlink;
        /* edge properties */
        typename graph_tool::eprop_map_t<std::string>::type elabel;
        typename graph_tool::eprop_map_t<int64_t>::type callgraphelink;

        Callgraph(graph_tool::GraphInterface& graph) : graph(graph){};
    };


	/**
	 * C++ representation of the graph.
	 *
	 * It stores the Python graph and LLVMData separately, although the Python graph contains the LLVMData.
	 * This is for convenience since the actual extraction is done with Cython.
	 */
	class Graph {
	  private:
		PyObject* graph;
		LLVMData* llvm_data;

	  public:
		Graph() : graph(nullptr), llvm_data(nullptr) {}
		Graph(PyObject* g, LLVMData& llvm_data) : graph(g), llvm_data(&llvm_data) {}

		/**
		 * convenience function to get the llvm module directly
		 */
		llvm::Module& get_module() { return llvm_data->get_module(); }

		LLVMData& get_llvm_data() { return *llvm_data; }

		PyObject* get_pygraph() { return graph; }

		CFG get_cfg();

        Callgraph get_callgraph();
	};
} // namespace ara::graph
