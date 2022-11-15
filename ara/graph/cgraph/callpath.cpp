#include "callpath.h"

#include "common/llvm_common.h"
#include "graph_data_pyx_wrapper.h"

namespace ara::graph {
	std::string CallPath::get_callsite_name(const SVF::PTACallGraphEdge& edge) const {
		if (!(edge.isIndirectCallEdge() | edge.isDirectCallEdge())) {
			return "";
		}
		const SVF::PTACallGraphEdge::CallInstSet& calls =
		    (edge.isIndirectCallEdge()) ? edge.getIndirectCalls() : edge.getDirectCalls();

		if (calls.size() != 1) {
			return "";
		}

		const SVF::CallICFGNode* node = *calls.begin();
		assert(node != nullptr && "call is null");
		const llvm::Instruction* inst = node->getCallSite();
		assert(inst != nullptr && "inst is null");

		return llvm_to_string(*inst);
	}

	void CallPath::check_and_assign(std::shared_ptr<CallGraph> call_graph) {
		if (this->call_graph) {
			assert(&call_graph->graph == &this->call_graph->graph && "Different call graphs are not supported.");
		} else {
			this->call_graph = call_graph;
		}
	}

	void CallPath::add_call_site(PyObject* call_graph, PyObject* edge) {
		check_and_assign(std::make_shared<CallGraph>(CallGraph::get(call_graph)));
		graph_tool::EdgeBase& edge_base = boost::python::extract<graph_tool::EdgeBase&>(edge);
		edges.emplace_back(edge_base.get_descriptor());
	}

	template <class G>
	void foo(SVF::PTACallGraphEdge** edge, graph::CallGraph& callgraph, graph_tool::GraphInterface::edge_t o_edge) {
		*edge = const_cast<SVF::PTACallGraphEdge*>(callgraph.get_svf_elink<G>(o_edge));
	}

	const SVF::PTACallGraphEdge* CallPath::svf_at(size_t index) const {
		assert(call_graph != nullptr && "CallGraph must not be null");
		SVF::PTACallGraphEdge* edge = nullptr;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    edge = const_cast<SVF::PTACallGraphEdge*>(
			        call_graph->get_svf_elink<typename std::remove_reference<decltype(g)>::type>(this->at(index)));
		    },
		    graph_tool::always_directed())(call_graph->graph.get_graph_view());
		return edge;
	}

	PyObject* CallPath::py_at(size_t index) {
		if (is_empty()) {
			throw std::out_of_range("CallPath has no elements.");
		}
		assert(call_graph != nullptr && "call graph is not initialized");
		auto gi = call_graph->graph;
		boost::python::object new_e;
		graph_tool::run_action<>()(gi, [&](auto&& graph) {
			return get_call_site_dispatched(std::forward<decltype(graph)>(graph), gi, index, new_e);
		})();
		return boost::python::incref(new_e.ptr());
	}

	std::string CallPath::print(bool call_site, bool instruction, bool functions) const {
		if (!(call_site || instruction || functions) || is_empty()) {
			return "CallPath()";
		}
		assert(call_graph != nullptr && "call graph is not initialized");
		std::stringstream ss;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) { print_dispatched(g, *call_graph, call_site, instruction, functions, ss); },
		    graph_tool::always_directed())(call_graph->graph.get_graph_view());
		return ss.str();
	}

	bool CallPath::operator==(const CallPath& other) const {
		if (edges.size() != other.edges.size()) {
			return false;
		}
		for (const auto& pair : boost::combine(edges, other.edges)) {
			if (pair.get<0>() != pair.get<1>()) {
				return false;
			}
		}
		return true;
	}

	void CallPath::pop_front() {
		if (is_empty()) {
			return;
		}
		edges.erase(edges.begin());
	}

	void CallPath::pop_back() {
		if (is_empty()) {
			return;
		}
		edges.pop_back();
	}

	bool CallPath::is_recursive() const {
		if (is_empty()) {
			return false;
		}
		assert(call_graph != nullptr && "call graph is not initialized");
		bool ret_value = false;
		graph_tool::gt_dispatch<>()([&](auto& g) { is_recursive_dispatched(g, ret_value); },
		                            graph_tool::always_directed())(call_graph->graph.get_graph_view());
		return ret_value;
	}

	PyObject* CallPath::get_python_obj() const { return py_get_callpath(*this); }

	std::ostream& operator<<(std::ostream& os, const CallPath& cp) {
		os << cp.print(/* call_site = */ true, /* instruction = */ false, /* functions = */ true);
		return os;
	}
} // namespace ara::graph
