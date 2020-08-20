#include "graph.h"

#include "common/exceptions.h"

#include <Python.h>
#include <boost/python.hpp>
#include <cassert>
#include <exception>

namespace ara::graph {
	// ABBType functions
	std::ostream& operator<<(std::ostream& str, const ABBType& ty) {
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
	std::ostream& operator<<(std::ostream& str, const CFType& ty) {
		switch (ty) {
		case lcf:
			return (str << "local control flow");
		case icf:
			return (str << "interprocedural control flow");
		case gcf:
			return (str << "global control flow");
		case f2a:
			return (str << "function to ABB");
		case a2f:
			return (str << "ABB to function");
		};
		assert(false);
		return str;
	}

	// ABB functions
	const llvm::CallBase* CFG::get_call_base(const ABBType type, const llvm::BasicBlock& bb) const {
		if (!(type == ABBType::call || type == ABBType::syscall)) {
			return nullptr;
		}
		const llvm::CallBase* call = llvm::dyn_cast<llvm::CallBase>(&bb.front());
		assert(call);
		return call;
	}

	const std::string CFG::bb_get_call(const ABBType type, const llvm::BasicBlock& bb) const {
		auto call = get_call_base(type, bb);
		if (!call) {
			return "";
		}
		const llvm::Function* func = call->getCalledFunction();
		// function are sometimes values with alias to a function
		if (!func) {
			const llvm::Value* value = call->getCalledValue();
			if (const llvm::Constant* alias = llvm::dyn_cast<llvm::Constant>(value)) {
				if (llvm::Function* tmp_func = llvm::dyn_cast<llvm::Function>(alias->getOperand(0))) {
					func = tmp_func;
				}
			}
		}
		if (!func) {
			return "";
		}
		return func->getName();
	}

	bool CFG::bb_is_indirect(const ABBType type, const llvm::BasicBlock& bb) const {
		auto call = get_call_base(type, bb);
		if (!call) {
			return false;
		}
		return call->isIndirectCall();
	}

	template <class Property>
	Property get_property(PyObject* prop_dict, const char* key) {
		PyObject* prop = PyObject_GetItem(prop_dict, PyUnicode_FromString(key));
		assert(prop != nullptr);

		PyObject* prop_any = PyObject_CallMethod(prop, "_get_any", nullptr);
		assert(prop_any != nullptr);

		boost::python::extract<boost::any> get_property(prop_any);
		assert(get_property.check());

		try {
			return boost::any_cast<Property>(get_property());
		} catch (boost::bad_any_cast& e) {
			std::cerr << "Bad any cast for attribute '" << key << "'" << std::endl;
			throw e;
		}
	}

	CFG Graph::get_cfg() {
		// extract self.cfg from Python
		PyObject* pycfg = PyObject_GetAttrString(graph, "cfg");
		assert(pycfg != nullptr);

		// GraphInterface
		PyObject* pycfg_graph = PyObject_GetAttrString(pycfg, "_Graph__graph");
		assert(pycfg_graph != nullptr);
		boost::python::extract<graph_tool::GraphInterface&> get_graph_interface(pycfg_graph);
		assert(get_graph_interface.check());
		CFG cfg(get_graph_interface());

		// Properties
#define MAP(Graph, Value, Type) Graph.Value = get_property<decltype(Graph.Value)>(Type, #Value);
#define VMAP(Value) MAP(cfg, Value, vprops)
#define EMAP(Value) MAP(cfg, Value, eprops)

		PyObject* vprops = PyObject_GetAttrString(pycfg, "vertex_properties");
		assert(vprops != nullptr);

		VMAP(name)
		VMAP(type)
		VMAP(is_function)
		VMAP(entry_bb)
		VMAP(exit_bb)
		VMAP(is_exit)
		VMAP(is_loop_head)
		VMAP(implemented)
		VMAP(syscall)
		VMAP(function)
		VMAP(arguments)

		PyObject* eprops = PyObject_GetAttrString(pycfg, "edge_properties");
		assert(eprops != nullptr);

		cfg.etype = get_property<decltype(cfg.etype)>(eprops, "type");
		EMAP(is_entry)

		return cfg;
	}

	CallGraph Graph::get_callgraph() {
		// extract self.callgraph from Python
		PyObject* pycallgraph = PyObject_GetAttrString(graph, "callgraph");
		assert(pycallgraph != nullptr);

		// get GraphInterface
		PyObject* pycallgraph_graph = PyObject_GetAttrString(pycallgraph, "_Graph__graph");
		assert(pycallgraph_graph != nullptr);
		boost::python::extract<graph_tool::GraphInterface&> get_graph_interface(pycallgraph_graph);
		assert(get_graph_interface.check());
		CallGraph callgraph(get_graph_interface());

		// Properties
		PyObject* vprops = PyObject_GetAttrString(pycallgraph, "vertex_properties");
		assert(vprops != nullptr);

		MAP(callgraph, function, vprops)
		MAP(callgraph, svf_vlink, vprops)

		PyObject* eprops = PyObject_GetAttrString(pycallgraph, "edge_properties");
		assert(eprops != nullptr);

		MAP(callgraph, callsite, eprops)
		MAP(callgraph, svf_elink, eprops)

		// TODO: the cfg graph attribute is not mappable with the above method. Fix it, when necessary.

		return callgraph;
	}
} // namespace ara::graph
