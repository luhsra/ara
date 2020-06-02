// vim: set noet ts=4 sw=4:
#include "load_os_config.h"

#include <Python.h>
#include <pyllco.h>

namespace ara::step {
	using namespace llvm;

	std::string LoadOSConfig::get_description() const {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void LoadOSConfig::fill_options() {}

	void LoadOSConfig::run(graph::Graph& graph) {
		logger.info() << "Execute LoadOSConfig step." << std::endl;
		PyObject* os = PyObject_GetAttrString(graph.get_pygraph(), "os");
		PyObject* config = PyObject_GetAttrString(os, "config");

		Module& module = graph.get_module();
		std::string prefix = "__ara_osconfig_";
		for (auto& global : module.globals()) {
			if (global.getName().str().rfind(prefix) == 0) {
				logger.error() << global << std::endl;
				PyObject* val_obj = get_obj_from_value(*global.getInitializer());
				PyObject* key = PyUnicode_FromString(global.getName().str().substr(prefix.length()).c_str());
				PyObject_SetItem(config, key, val_obj);
				Py_DECREF(val_obj);
				Py_DECREF(key);
			}
		}
		Py_DECREF(config);
		Py_DECREF(os);
	}
} // namespace ara::step
