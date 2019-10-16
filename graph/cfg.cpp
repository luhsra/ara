#include "common/exceptions.h"
#include "graph.h"

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

	// CFType functions
	ostream& operator<<(ostream& str, const CFType& ty) {
		switch (ty) {
		case lcf:
			return (str << "local control flow");
		case icf:
			return (str << "interprocedural control flow");
		case gcf:
			return (str << "global control flow");
		};
		assert(false);
		return str;
	}

	// ABB functions
	const CallBase* get_call_base(const ABBType type, const BasicBlock& bb) {
		if (!(type == ABBType::call || type == ABBType::syscall)) {
			return nullptr;
		}
		const CallBase* call = dyn_cast<CallBase>(&bb.front());
		assert(call);
		return call;
	}

	std::string ABB::get_call() const {
		auto call = get_call_base(type, *entry_bb);
		if (!call) {
			return "";
		}
		const llvm::Function* func = call->getCalledFunction();
		// function are sometimes values with alias to a function
		if (!func) {
			const llvm::Value* value = call->getCalledValue();
			if (const llvm::Constant* alias = dyn_cast<Constant>(value)) {
				if (llvm::Function* tmp_func = dyn_cast<llvm::Function>(alias->getOperand(0))) {
					func = tmp_func;
				}
			}
		}
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

	// ABBEdge functions
	ostream& operator<<(ostream& str, const ABBEdge& abb_edge) {
		return (str << "ABBEdge(type=" << abb_edge.type << ")");
	}

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

	FunctionDescriptor& ABBGraph::add_function(const std::string name, llvm::Function* llvm_func, bool implemented) {
		FunctionDescriptor& func = this->create_subgraph();

		ara::cfg::Function& f = boost::get_property(func);
		f.name = name;
		f.func = llvm_func;
		f.implemented = implemented;

		function_map.insert(pair<const llvm::Function*, std::reference_wrapper<FunctionDescriptor>>(llvm_func, func));

		return func;
	}

	ABBGraph::vertex_descriptor ABBGraph::back_map(const llvm::BasicBlock* bb) {
		auto it = abb_map.find(bb);
		if (it == abb_map.end()) {
			throw VertexNotFound();
		}
		return (*it).second;
	}

	FunctionDescriptor& ABBGraph::back_map(const llvm::Function* func) {
		auto it = function_map.find(func);
		if (it == function_map.end()) {
			throw FunctionNotFound();
		}
		return (*it).second;
	}

	FunctionDescriptor& ABBGraph::get_subgraph(const ABBGraph::vertex_descriptor v) {
		// TODO more efficient algorithm?
		for (auto& function : boost::make_iterator_range(this->children())) {
			auto result = function.find_vertex(v);
			if (result.second) {
				return function;
			}
		}
		throw ara::FunctionNotFound();
	}

	const FunctionDescriptor& ABBGraph::get_function_by_name(const std::string name) const {
		// TODO more efficient algorithm?
		for (auto& function : boost::make_iterator_range(this->children())) {
			if (boost::get_property(function).name == name) {
				return function;
			}
		}
		throw ara::FunctionNotFound();
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
