#include "exceptions.h"
#include "graph.h"

#include "common/llvm_common.h"

#include <cassert>

using namespace llvm;
using namespace std;

namespace ara::cfg {
	// ABBType functions
	ostream& operator<<(ostream& str, const ABBType& ty) {
		switch (ty) {
		case syscall:
			return (str << "syscall");
		case call:
			return (str << "call");
		case computation:
			return (str << "computation");
		case not_implemented:
			return (str << "not_implemented");
		};
		assert(false);
		return str;
	}

	// ABB functions
	std::unique_ptr<FakeCallBase> get_call_base(const ABBType type, const BasicBlock& bb) {
		if (!(type == ABBType::call || type == ABBType::syscall)) {
			return nullptr;
		}
		auto call = FakeCallBase::create(&bb.front());
		assert(call);
		return std::move(call);
	}

	std::string ABB::get_call() const {
		auto call = get_call_base(type, *entry_bb);
		if (!call) {
			return "";
		}
		const llvm::Function* func = call->getCalledFunction();
		if (!func) {
			return "";
		}
		return func->getName();
	}

	bool ABB::is_indirect() const {
		auto call = get_call_base(type, *entry_bb);
		if (!call) {
			return false;
		}
		return call->isIndirectCall();
	}

	ostream& operator<<(ostream& str, const ABB& abb) { return (str << "ABB(" << abb.name << ")"); }

	// Function functions
	ostream& operator<<(ostream& str, const Function& func) { return (str << "Function(" << func.name << ")"); }

	// ABBGraph functions
	ABBGraph::vertex_descriptor ABBGraph::add_vertex(string name, ABBType type, llvm::BasicBlock* entry_bb,
	                                                 llvm::BasicBlock* exit_bb, FunctionDescriptor& function) {
		ABBGraph::vertex_descriptor vertex = boost::add_vertex(function);
		function[vertex].name = name;
		function[vertex].type = type;
		function[vertex].entry_bb = entry_bb;
		function[vertex].exit_bb = exit_bb;

		vertex = function.local_to_global(vertex);

		abb_map.insert(pair<const BasicBlock*, ABBGraph::vertex_descriptor>(entry_bb, vertex));
		abb_map.insert(pair<const BasicBlock*, ABBGraph::vertex_descriptor>(exit_bb, vertex));

		return vertex;
	}

	pair<ABBGraph::edge_descriptor, bool> ABBGraph::add_edge(ABBGraph::vertex_descriptor v1,
	                                                         ABBGraph::vertex_descriptor v2) {
		return boost::add_edge(v1, v2, *this);
	}

	ABBGraph::vertex_descriptor ABBGraph::back_map(const llvm::BasicBlock* bb) {
		auto it = abb_map.find(bb);
		if (it == abb_map.end()) {
			throw vertex_not_found;
		}
		return (*it).second;
	}

	const FunctionDescriptor& ABBGraph::get_subgraph(const ABBGraph::vertex_descriptor v) const {
		// TODO more efficient algorithm?
		for (auto& function : boost::make_iterator_range(this->children())) {
			auto result = function.find_vertex(v);
			if (result.second) {
				return function;
			}
		}
	}

	ostream& operator<<(ostream& str, const ABBGraph& graph) {
		// probably not the best dump format, feel free to improve
		const unsigned indent = 2;
		str << "ABBGraph(\n";
		for (const auto& function : boost::make_iterator_range(graph.children())) {
			const ara::cfg::Function& afunc = boost::get_property(function);
			str << string(indent * 1, ' ') << "Function " << afunc.name << " (";
			bool one_abb = false;
			for (auto abb : boost::make_iterator_range(vertices(function))) {
				auto abb_prop = graph[function.local_to_global(abb)];
				str << "\n" << string(indent * 2, ' ') << abb_prop;
				one_abb = true;
			}
			if (one_abb) {
				str << "\n" << string(indent * 1, ' ');
			}
			str << ")\n";
		}

		if (num_edges(graph) > 0) {
			str << "\n" << string(indent * 1, ' ') << "Edges:\n";
		}
		for (auto edge : boost::make_iterator_range(edges(graph))) {
			str << string(indent * 2, ' ') << "Edge " << graph[source(edge, graph)] << " -> "
			    << graph[target(edge, graph)] << "\n";
		}

		str << ")";

		return str;
	}

} // namespace ara::cfg
