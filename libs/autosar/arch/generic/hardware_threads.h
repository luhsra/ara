// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __HARDWARE_THREADS_H__
#define __HARDWARE_THREADS_H__

#define MAX_CPUS 16

#include "osek_types.h"

#include <stdint.h>

extern _Atomic(bool) ipi_cleared[MAX_CPUS];
namespace arch {

	typedef enum {
		SYNC_PRE_STARTUPHOOK = 0,
		SYNC_POST_STARTUPHOOK = 1,
		SYNC_PRE_SHUTDOWNHOOK = 2,
		SYNC_POST_SHUTDOWNHOOK = 3,
		SYNC_MAX = 4,
	} cpu_sync_point_t;

	/**
	 * \brief Starts another hardware thread (generic interface)
	 *
	 * \param hardware_number Identifies the hardware element that is started
	 * \param bottom_of_stack The bottom (lowest address) of the stack for the
	 *                        hardware stack
	 * \param size_of_stack The size of the given stack
	 * \param startup_function A function pointer to the function that will be
	 *                         run on the started hardware thread
	 **/
	StatusType start_hardware_thread(unsigned int hardware_number, void* bottom_of_stack, unsigned int size_of_stack);

	bool cpu_online(int cpuid);
	int get_cpuid();
	unsigned int get_num_cores();
	void init_cpuid();
	void sync_all_hardware_threads(cpu_sync_point_t);
	void stop_hardware_thread();
	void stop_other_hardware_threads();
	
} // namespace arch

#endif
