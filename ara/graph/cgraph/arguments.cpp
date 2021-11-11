#include "arguments.h"

#include "common/llvm_common.h"
#include "graph_data_pyx_wrapper.h"

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
		if (is_determined()) {
			return values.begin()->second;
		}
		auto it = values.find(key);
		if (it != values.end()) {
			return it->second;
		}

		// copy key
		CallPath r_key = key;

		// check for less specific paths
		while (!r_key.is_empty()) {
			r_key.pop_front();
			auto it = values.find(r_key);
			if (it != values.end()) {
				return it->second;
			}
		}
		throw std::out_of_range("Argument has no such value.");
	}

	std::ostream& operator<<(std::ostream& os, const Argument& arg) {
		os << "Argument(";
		if (arg.size() == 0) {
			os << "empty)";
			return os;
		}
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
