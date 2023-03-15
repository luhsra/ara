// SPDX-FileCopyrightText: 2020 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:
#include "load_freertos_config.h"

#include <Python.h>
#include <pyllco.h>

namespace ara::step {
	using namespace llvm;

	const std::string prefix = "__ara_osconfig_";

	std::string LoadFreeRTOSConfig::get_description() {
		return "Retrieve config values from IR. \n"
		       "Stores all global values named \"" +
		       prefix + "*\" into graph.os.config dict";
	}

	void LoadFreeRTOSConfig::run() {
		PyObject* os = PyObject_GetAttrString(graph.get_pygraph(), "os");
		PyObject* config = PyObject_GetAttrString(os, "config");

		Module& module = graph.get_module();
		for (auto& global : module.globals()) {
			if (global.getName().str().rfind(prefix) == 0) {
				logger.debug() << global << std::endl;
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
