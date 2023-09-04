// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup posix
 * @brief Architecture-specific startup code
 */

#include "dispatch.h"
#include "itimer.h"
#include "spinlock.h"

/** Initialisation stub for generic startup code */
extern "C" void init_generic();

using namespace arch;

bool initialized = false;
os::Spinlock init_lock;

//!< i386 specific startup code
extern "C" void arch_startup() {
	init_lock.lock();

	if (!initialized) {
		arch::init_cpuid();
		// global constructors habe been are already called before main.

		Machine::init();

		Dispatcher::init();

		/* set affinity to CPU 0*/
		cpu_set_t cpuset;
		pthread_t thread;
		thread = pthread_self();
		CPU_ZERO(&cpuset);
		CPU_SET(0, &cpuset);
		pthread_setaffinity_np(thread, sizeof(cpuset), &cpuset);

		// setup timer
		// ITimer::init();

		// Proceed to generic initialisation
		init_generic();
		initialized = true;
	}

	init_lock.unlock();
}
