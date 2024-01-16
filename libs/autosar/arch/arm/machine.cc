// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "machine.h"
#include "hardware_threads.h"
#include "syscall.h"
#include "pmu.h"

using namespace arch;

_Atomic(bool) ipi_cleared[MAX_CPUS];

void Machine::trigger_interrupt(uint8_t irq, uint8_t cpuid, bool sync) {
    // TODO: check if CPU is online

    if (!sync) {
        arch::GIC::trigger(irq, cpuid);
        return;
    }

	/* synchronized interrupt: wait until target core does reschedule */
	ipi_cleared[cpuid] = false;
	
    arch::GIC::trigger(irq, cpuid);
#ifdef PMU_TRACE_A
    //checkpoint 3
    arch::PMU::trace_cycles();
#endif
    
	while (ipi_cleared[cpuid] == false)
    {
        Machine::nop();
    }
#ifdef PMU_TRACE_A
    // checkpoint 4
    arch::PMU::trace_cycles();
#endif
	debug_core << __FUNCTION__ << " completed" << endl;
}

void Machine::trigger_interrupt_from_user(uint8_t irq, uint8_t cpuid, bool sync) {
    // limit irqs
    irq = irq % 16;

    trigger_interrupt(irq, cpuid, sync);
 }
