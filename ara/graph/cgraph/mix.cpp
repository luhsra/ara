#include "mix.h"

#include <cassert>

#define EQUAL_OPERATOR(Type)                                                                                           \
	bool operator==(const Type& ty, const int i) { return static_cast<int>(ty) == i; }                                 \
	bool operator==(const int i, const Type& ty) { return static_cast<int>(ty) == i; }

#define NOT_EQUAL_OPERATOR(Type)                                                                                       \
	bool operator!=(const Type& ty, const int i) { return static_cast<int>(ty) != i; }                                 \
	bool operator!=(const int i, const Type& ty) { return static_cast<int>(ty) != i; }

namespace ara::graph {
	// ABBType functions
	std::ostream& operator<<(std::ostream& str, const ABBType& ty) {
		switch (ty) {
		case ABBType::syscall:
			return (str << "syscall");
		case ABBType::call:
			return (str << "call");
		case ABBType::computation:
			return (str << "computation");
		case ABBType::not_implemented:
			return (str << "not_implemented");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(ABBType)
	NOT_EQUAL_OPERATOR(ABBType)

	// NodeLevel functions
	std::ostream& operator<<(std::ostream& str, const NodeLevel& ty) {
		switch (ty) {
		case NodeLevel::function:
			return (str << "function");
		case NodeLevel::abb:
			return (str << "abb");
		case NodeLevel::bb:
			return (str << "bb");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(NodeLevel)
	NOT_EQUAL_OPERATOR(NodeLevel)

	// CFType functions
	std::ostream& operator<<(std::ostream& str, const CFType& ty) {
		switch (ty) {
		case CFType::lcf:
			return (str << "local control flow");
		case CFType::icf:
			return (str << "interprocedural control flow");
		case CFType::gcf:
			return (str << "global control flow");
		case CFType::f2a:
			return (str << "function to ABB");
		case CFType::a2b:
			return (str << "ABB to BB");
		case CFType::f2b:
			return (str << "function to BB");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(CFType)
	NOT_EQUAL_OPERATOR(CFType)

	// SyscallCategory functions
	std::ostream& operator<<(std::ostream& str, const SyscallCategory& ty) {
		switch (ty) {
		case SyscallCategory::undefined:
			return (str << "undefined");
		case SyscallCategory::every:
			return (str << "every");
		case SyscallCategory::create:
			return (str << "create");
		case SyscallCategory::comm:
			return (str << "comm");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(SyscallCategory)
	NOT_EQUAL_OPERATOR(SyscallCategory)

	// SigType functions
	std::ostream& operator<<(std::ostream& str, const SigType& ty) {
		switch (ty) {
		case SigType::undefined:
			return (str << "undefined");
		case SigType::value:
			return (str << "value");
		case SigType::symbol:
			return (str << "symbol");
		case SigType::instance:
			return (str << "instance");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(SigType)
	NOT_EQUAL_OPERATOR(SigType)

	// GraphTypes functions
	std::ostream& operator<<(std::ostream& str, const GraphTypes& ty) {
		switch (ty) {
		case GraphTypes::ABB:
			return (str << "Abb");
		case GraphTypes::INSTANCE:
			return (str << "Instance");
		case GraphTypes::CALLGRAPH:
			return (str << "CallGraph");
		case GraphTypes::SVFG:
			return (str << "SVFG");
		};
		assert(false);
		return str;
	}

	EQUAL_OPERATOR(GraphTypes)
	NOT_EQUAL_OPERATOR(GraphTypes)
} // namespace ara::graph
