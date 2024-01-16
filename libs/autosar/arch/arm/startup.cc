// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup ARM
 * @brief Architecture-specific startup code
 */

#include "gic.h"
#include "machine.h"
#include "mmu.h"
#include "output.h"
#include "syscall.h"
#include "timer.h"
#include "os.h"
#include "mmu.h"
#include <stdint.h>

#include <spinlock.h>

/** Initialisation stub for generic startup code */
extern "C" void init_generic();
extern "C" void run_constructors(void);

extern "C" {
__attribute__((section(".kernel_stack"))) char os_stack[4096*MAX_CPUS];
}

using namespace arch;

//!< arm specific startup code
extern "C" void arch_startup() {
	// run constructors of global objects

	if (arch::get_cpuid() == 0) {
		run_constructors();

		// setup generic interrupt controller
		GIC::init_dist();
		GIC::set_irq_priority(IRQ_DISPATCH, IRQ_PRIO_DISPATCH);
		GIC::set_irq_priority(IRQ_RESCHEDULE, IRQ_PRIO_RESCHEDULE);

		MMU::setup_pagetable();
		MMU::enable();
		kout << endl;
	}

	//Machine::setup_caches();

	// wait_for_debugger();

	GIC::init_proc();

	/*
	// setup system stack
	// TODO

	// setup paging

	*/


#if defined(PMU_TRACE_A) || defined(PMU_TRACE_B) || defined(PMU_TRACE_C)

	//arch::PMU::start(); // start on all cores
#else
	// setup Private Timer
	//Timer::init();
#endif

	// switch to user mode preserving SP
	uint32_t sp;
	asm volatile("mov %0, sp" : "=r"(sp));
	Machine::switch_mode(Machine::USER);
	asm volatile("mov sp, %0" ::"r"(sp));


	// unblock ISR2s by lowering GIC task priority
	GIC::set_task_prio(IRQ_PRIO_LOWEST);

	//kout << "SSSSSS [[[[[[ Starting dOSEK ]]]]]]" << endl;
	//kout << "APP_BOOT" << endl;
	// Proceed to generic initialisation
	init_generic();
}
