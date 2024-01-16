// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "dispatch.h"
#include "gic.h"
#include "machine.h"
#include "os/scheduler/scheduler.h"
#include "syscall.h"

extern "C" uint8_t _estack_os;

namespace arch {

	__attribute__((noreturn)) IRQ_HANDLER(IRQ_RESCHEDULE) {
		// block ISR2s by raising GIC task priority
		GIC::set_task_prio(IRQ_PRIO_SYSCALL);

		// change to OS page directory
		// PageDirectory::enable(pagedir_os);

		// reset save_sp to detect IRQ from non-userspace in idt.S
		save_sp[arch::get_cpuid()] = 0;

		// set user SP
		//Machine::switch_mode(Machine::SYSTEM);
		//asm volatile("mov sp, %0" ::"r"(&_estack_os - 2048 - 4096*arch::get_cpuid()));
		//Machine::switch_mode(Machine::SUPERVISOR);

		//asm volatile("mov lr, %0" ::"r"((uint32_t)__OS_ASTSchedule));
		//asm volatile("subs pc, lr, #0");
		__OS_ASTSchedule(0);

		Machine::unreachable();
		while (1)
			; // should be unreachable
	}

}; // namespace arch
