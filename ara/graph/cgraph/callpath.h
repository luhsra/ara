// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "graph.h"

#include <boost/range/adaptor/reversed.hpp>
#include <graph_python_interface.hh>
#include <memory>

namespace ara::graph {
	class CallPath : boost::equality_comparable<CallPath> {
	  private:
		std::vector<graph_tool::GraphInterface::edge_t> edges;
		// This CallGraph should be filled, as soon as CallPath is not empty anymore.
		std::shared_ptr<CallGraph> call_graph;

		std::string get_callsite_name(const SVF::PTACallGraphEdge& edge) const;

		void check_and_assign(std::shared_ptr<CallGraph> call_graph);

		template <typename Graph>
		void add_call_site_dispatched(Graph& g, CallGraph& call_graph, const SVF::PTACallGraphEdge& edge) {
			typename boost::graph_traits<Graph>::edge_descriptor mapped_edge = call_graph.back_map(g, edge);
			edges.emplace_back(mapped_edge);
		}

		template <typename Graph>
		void get_call_site_dispatched(Graph& g, graph_tool::GraphInterface& gi, size_t index,
		                              boost::python::object& new_e) {
			auto gp = graph_tool::retrieve_graph_view<Graph>(gi, g);
			new_e = boost::python::object(graph_tool::PythonEdge<Graph>(gp, edges.at(index)));
		}

		template <typename Graph>
		void is_recursive_dispatched(Graph& g, bool& ret_value) const {
			std::unordered_set<typename boost::graph_traits<Graph>::vertex_descriptor> func_set;
			for (const auto& edge : boost::adaptors::reverse(edges)) {
				const auto target = boost::target(edge, g);
				if (func_set.find(target) != func_set.end()) {
					ret_value = true;
					return;
				}
				func_set.emplace(target);
			}
			ret_value = false;
		}

		template <typename Graph>
		void print_dispatched(Graph& g, const CallGraph& call_graph, bool call_site, bool instruction, bool functions,
		                      std::stringstream& ss) const {
			bool first = true;
			ss << "Callpath(";
			for (const auto& edge : edges) {
				if (!first) {
					ss << ", ";
				}
				first = false;

				ss << "[";
				if (call_site) {
					ss << call_graph.callsite_name[edge];
				}
				if (instruction) {
					if (call_site) {
						ss << ", ";
					}
					ss << get_callsite_name(safe_deref(call_graph.get_svf_elink<Graph>(edge)));
				}
				if (functions) {
					if (call_site || instruction) {
						ss << ", ";
					}
					ss << call_graph.function_name[boost::source(edge, g)] << " -> "
					   << call_graph.function_name[boost::target(edge, g)];
				}
				ss << "]";
			}
			ss << ")";
		}

		friend std::ostream& operator<<(std::ostream& os, const CallPath& cp);

	  public:
		CallPath() : edges(), call_graph(nullptr) {}

		void add_call_site(std::shared_ptr<CallGraph> call_graph, const SVF::PTACallGraphEdge& call_site) {
			check_and_assign(call_graph);
			graph_tool::gt_dispatch<>()([&](auto& g) { add_call_site_dispatched(g, *call_graph, call_site); },
			                            graph_tool::always_directed())(call_graph->graph.get_graph_view());
		}

		void add_call_site(PyObject* call_graph, PyObject* edge);

		const graph_tool::GraphInterface::edge_t at(size_t index) const { return edges.at(index); }
		graph_tool::GraphInterface::edge_t at(size_t index) { return edges.at(index); }
		const SVF::PTACallGraphEdge* svf_at(size_t index) const;
		PyObject* py_at(size_t index);

		std::string print(bool call_site = false, bool instruction = false, bool functions = false) const;

		bool is_empty() const { return size() == 0; }

		size_t size() const { return edges.size(); }

		bool operator==(const CallPath& other) const;

		std::size_t hash() const { return boost::hash_range(edges.begin(), edges.end()); }

		/**
		 * Deletes the most far away call from the CallPath.
		 */
		void pop_front();

		/**
		 * Deletes the nearest call from the CallPath.
		 */
		void pop_back();

		/**
		 * Check if the call path is recursive, aka, contains two equal edges.
		 */
		bool is_recursive() const;

		/**
		 * Common iterators that return a std::pair<CallPath, llvm::Value&>.
		 */
		auto begin() noexcept { return edges.begin(); }
		const auto begin() const noexcept { return edges.begin(); }
		const auto cbegin() const noexcept { return edges.cbegin(); }

		auto end() noexcept { return edges.end(); }
		const auto end() const noexcept { return edges.end(); }
		const auto cend() const noexcept { return edges.cend(); }

		/**
		 * Return a copy of the current object as Python object.
		 */
		PyObject* get_python_obj() const;
	};

	std::ostream& operator<<(std::ostream& os, const CallPath& cp);
} // namespace ara::graph
