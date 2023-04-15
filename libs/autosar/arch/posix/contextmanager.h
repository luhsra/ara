// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef CONTEXT_MANAGER_H
#define CONTEXT_MANAGER_H

#include "ucontextimpl.h"

#include <map>

namespace arch {

	class ContextManager {
		typedef std::map<os::scheduler::Task::id_t, arch::PosixContext> ctxmap_t;
		ctxmap_t map;

	  public:
		arch::PosixContext& getContext(int id) { return map[id]; }

		arch::PosixContext& getContext(const os::scheduler::Task task) { return map[task.id]; }
	};

}; // namespace arch

#endif
