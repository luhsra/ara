// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "py_util.h"

namespace ara::step::py_util {

	void py_assert(bool cond, const std::string&& msg, Logger& logger, const PyObject* error_with_obj) {
		if (!cond) {
			logger.err() << std::flush;
			logger.err() << "py_assert: " << msg << std::endl;
			if (PyErr_Occurred()) {
				PyErr_Print();
			}
			if (error_with_obj != nullptr) {
				PyTypeObject* type = error_with_obj->ob_type;
				const char* type_str = type->tp_name;
				logger.err() << "py_assert: the type of the object involved was: " << type_str << std::endl;
			}
			abort();
		}
	}

	void handle_py_error(bool display_msg) {
		if (PyErr_Occurred()) {
			if (display_msg) {
				PyErr_Print();
			}
			abort();
		}
	}

} // namespace ara::step::py_util
