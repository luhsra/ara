#include "exceptions.h"
#include "graph.h"

using namespace llvm;

namespace ara::cfg {
	ABBGraph::vertex_descriptor ABBGraph::add_vertex(std::string name, ABBType type, llvm::BasicBlock* entry_bb,
	                                                 llvm::BasicBlock* exit_bb) {
		ABBGraph::vertex_descriptor vertex = boost::add_vertex(*this);
		(*this)[vertex].name = name;
		(*this)[vertex].type = type;
		(*this)[vertex].entry_bb = entry_bb;
		(*this)[vertex].exit_bb = exit_bb;

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
} // namespace ara::cfg
