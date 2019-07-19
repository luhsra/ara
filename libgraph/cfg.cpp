#include "exceptions.h"
#include "graph.h"

using namespace llvm;

namespace ara::cfg {
	// ABBType functions
	std::ostream& operator<<(std::ostream& str, const ABBType& ty) {
		switch (ty) {
			case syscall:
				return (str << "syscall");
			case call:
				return (str << "syscall");
			case computation:
				return (str << "computation");
		};
	}

	// ABB functions
	std::ostream& operator<<(std::ostream& str, const ABB& abb) {
		return (str << "ABB(" << abb.name << ")");
	}

	// Function functions
	std::ostream& operator<<(std::ostream& str, const Function& func) {
		return (str << "Function(" << func.name << ")");
	}

	// ABBGraph functions
	ABBGraph::vertex_descriptor ABBGraph::add_vertex(std::string name, ABBType type, llvm::BasicBlock* entry_bb,
	                                                 llvm::BasicBlock* exit_bb, FunctionDescriptor& function) {
		ABBGraph::vertex_descriptor vertex = boost::add_vertex(function);
		function[vertex].name = name;
		function[vertex].type = type;
		function[vertex].entry_bb = entry_bb;
		function[vertex].exit_bb = exit_bb;

		vertex = function.local_to_global(vertex);

		abb_map.insert(std::pair<const BasicBlock*, ABBGraph::vertex_descriptor>(entry_bb, vertex));
		abb_map.insert(std::pair<const BasicBlock*, ABBGraph::vertex_descriptor>(exit_bb, vertex));

		return vertex;
	}

	std::pair<ABBGraph::edge_descriptor, bool> ABBGraph::add_edge(ABBGraph::vertex_descriptor v1,
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

	std::ostream& operator<<(std::ostream& str, const ABBGraph& graph) {
		return (str << "ABBGraph()");
	}

} // namespace ara::cfg
