// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "dispatch.h"

#include "gic.h"
#include "machine.h"
#include "os/util/assert.h"
#include "os/util/encoded.h"
#include "os/util/inline.h"
#include "tcb.h"

namespace arch {

	extern TCB* const OS_tcbs[];

	/** \brief Startup stackpointer (save location) */
	volatile void* startup_sp = 0;

	uint32_t save_sp[MAX_CPUS] = {0};

	volatile uint16_t dispatch_task[MAX_CPUS];

	/** \brief Dispatch interrupt handler
	 *
	 * This interrupt is called after the next task is determined by the scheduler in ring 3
	 * and performs the actual dispatching in ring 0.
	 */
	// IRQ_HANDLER(IRQ_DISPATCH) {
	void __attribute__((noreturn)) Dispatcher::do_dispatch() {
		uint16_t id = dispatch_task[arch::get_cpuid()];

		// get TCB
		const TCB* const tcb = OS_tcbs[id];

		// set save_sp
		if (save_sp[arch::get_cpuid()] != 0) {
			debug_core << "ERROR" << endl;
			CALL_HOOK(FaultDetectedHook, LOGIC_ERRORdetected, 0, 0);
		}
		save_sp[arch::get_cpuid()] = id;

		// set new page directory
		// MMU::switch_task(id);

		// push instruction pointer
		uint32_t ip;
		uint32_t* sp = (uint32_t*)tcb->get_sp();
		tcb->check_sp();

		// send end-of-interrupt signal
		GIC::set_task_prio(IRQ_PRIO_LOWEST);

		if (tcb->is_running()) {
			// resume from saved IP on stack
			ip = *(sp - 1);

			asm volatile("mov r1, %0 \n\t"
			             "mov r0, %1  \n\t"
			             "bx r1" ::"l"(ip),
			             "l"(sp)
			             : "r0", "r1");
		} else {
			// start function from beginning
			ip = (uint32_t)tcb->fun;

			// Set the user's stack pointer
			// We leave to the user mode in system mode
			asm volatile("mov r1, %0 \n\t"
			             "mov r0, %1  \n\t"
			             "cps #31  \n\t"
			             "mov sp, r0  \n\t"
			             "bx r1" ::"l"(ip),
			             "l"(sp)
			             : "r0", "r1");
		}

		Machine::unreachable();
		return 0;
	}

} // namespace arch
