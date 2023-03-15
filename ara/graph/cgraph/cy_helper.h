// SPDX-FileCopyrightText: 2021 Jan Neugebauer
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * Helper function for cython incompabilities. DO NOT USE IN OTHER C++-PARTS!
 */

#pragma once

#include "os.h"

#include <Python.h>
#include <memory>
#include <pyllco.h>

namespace ara::graph {
	inline SigType to_sigtype(int ty) { return static_cast<SigType>(ty); }

	PyObject* safe_get_value(std::shared_ptr<Argument> argument, const CallPath& call_path) {
		try {
			return get_obj_from_value(argument->get_value(call_path));
		} catch (const std::out_of_range&) {
			return Py_None;
		}
	}
} // namespace ara::graph
