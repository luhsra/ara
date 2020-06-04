#pragma once

#include "../mix.py"
#include "common/exceptions.h"
#include "llvm_data.h"

#include <Python.h>
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

	  private:
		const std::string bb_get_call(const ABBType type, const llvm::BasicBlock& bb) const;
		bool bb_is_indirect(const ABBType type, const llvm::BasicBlock& bb) const;
		const llvm::CallBase* get_call_base(const ABBType type, const llvm::BasicBlock& bb) const;
	};

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
	auto filter_by_abb(const unsigned type_filter, Graph& g, const CFG& cfg)
	    -> boost::filtered_graph<Graph, boost::keep_all, ABBTypeFilter> {
		return boost::filtered_graph<Graph, boost::keep_all, ABBTypeFilter>(g, boost::keep_all(),
		                                                                    ABBTypeFilter(type_filter, &cfg));
	}

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
	};
} // namespace ara::graph
