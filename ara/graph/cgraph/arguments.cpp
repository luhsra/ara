#include "arguments.h"

#include "common/llvm_common.h"
#include "graph_data_pyx.h"

#include <llvm/Support/raw_ostream.h>

namespace boost::detail {
	std::size_t hash_value(const boost::detail::adj_edge_descriptor<long unsigned int>& edge) {
		std::size_t seed = 0;
		boost::hash_combine(seed, edge.s);
		boost::hash_combine(seed, edge.t);
		boost::hash_combine(seed, edge.idx);
		return seed;
	}
} // namespace boost::detail

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

		const SVF::CallBlockNode* node = *calls.begin();
		assert(node != nullptr && "call is null");
		const llvm::Instruction* inst = node->getCallSite();
		assert(inst != nullptr && "inst is null");

		return llvm_to_string(*inst);
	}

	std::string CallPath::print(const CallGraph& call_graph, bool call_site, bool instruction, bool functions) const {
		if (!(call_site || instruction || functions)) {
			return "CallPath()";
		}
		std::stringstream ss;
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) { print_dispatched(g, call_graph, call_site, instruction, functions, ss); },
		    graph_tool::always_directed())(call_graph.graph.get_graph_view());
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

	std::ostream& operator<<(std::ostream& os, const CallPath& cp) {
		os << "CallPath(";
		bool first = true;
		if (cp.verbose) {
			for (const auto& edge : cp.edge_descriptions) {
				if (!first) {
					os << ", ";
				}
				first = false;
				os << edge;
			}
		} else {
			for (const auto& edge : cp.edges) {
				if (!first) {
					os << ", ";
				}
				first = false;
				os << edge.s << "->" << edge.t << " (" << edge.idx << ")";
			}
		}
		os << ')';
		return os;
	}

	struct Argument::ArgumentSharedEnabler : public Argument {
		template <typename... Args>
		ArgumentSharedEnabler(Args&&... args) : Argument(std::forward<Args>(args)...) {}
	};
	std::shared_ptr<Argument> Argument::get(const llvm::AttributeSet& attrs) {
		return std::make_shared<ArgumentSharedEnabler>(attrs);
	}
	std::shared_ptr<Argument> Argument::get(const llvm::AttributeSet& attrs, llvm::Value& value) {
		return std::make_shared<ArgumentSharedEnabler>(attrs, value);
	}

	bool Argument::is_constant() const {
		for (const auto& value : values) {
			if (!llvm::isa<llvm::Constant>(value.second)) {
				return false;
			}
		}
		return true;
	}

	bool Argument::has_value(const CallPath& key) const { return values.find(key) != values.end(); }

	llvm::Value& Argument::get_value(const CallPath& key) const {
		if (is_determined() && key.is_empty()) {
			return values.begin()->second;
		}
		return values.at(key);
	}

	std::ostream& operator<<(std::ostream& os, const Argument& arg) {
		os << "Argument(";

		if (arg.is_determined()) {
			os << llvm_to_string(arg.get_value());
		} else {
			bool first = true;
			for (const auto& entry : arg) {
				if (!first) {
					os << ", ";
				}
				first = false;

				os << entry.first << ": " << llvm_to_string(entry.second);
			}
		}

		os << ", constant=";
		if (arg.is_constant()) {
			os << "true";
		} else {
			os << "false";
		}

		os << ")";
		return os;
	}

	std::ostream& operator<<(std::ostream& os, const Arguments& args) {
		os << "Arguments(";
		bool first = true;
		for (const auto& arg : args) {
			if (!first) {
				os << ", ";
			}
			first = false;
			if (arg == nullptr) {
				os << "nullptr";
			} else {
				os << *arg;
			}
		}
		if (args.has_return_value()) {
			os << ", return_value=" << *args.get_return_value();
		}
		os << ")";
		return os;
	}

	PyObject* Arguments::get_python_obj() { return py_get_arguments(shared_from_this()); }
} // namespace ara::graph
