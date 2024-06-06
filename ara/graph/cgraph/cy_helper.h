// SPDX-FileCopyrightText: 2021 Jan Neugebauer
// SPDX-FileCopyrightText: 2022 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * Helper function for cython incompabilities. DO NOT USE IN OTHER C++-PARTS!
 */

#pragma once

// see https://github.com/cython/cython/issues/5812
#ifndef WITH_THREAD
#define WITH_THREAD
#endif

#include "os.h"

#include <Python.h>
#include <memory>
/* We are doing nesting of Cython modules. Therefore, Cython throws a lot of "Please do not define the '__PYX_EXTERN_C'
 * macro externally" errors. If we define it manually here, it silences these warnings.
 */
// clang-format off
#define CYTHON_EXTERN_C extern "C++"
#include "pyllco.h"
// clang-format on

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
