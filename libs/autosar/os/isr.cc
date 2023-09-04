// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "machine.h"
#include "os.h"

/**
 * \brief Methods for interrupt disabling/enabling. This pair cannot
 *        be stacked.
 **/
void AUTOSAR_DisableAllInterrupts() { Machine::disable_interrupts(); }

void AUTOSAR_EnableAllInterrupts() { Machine::enable_interrupts(); }

/**
 * \brief Same as disable/enable but can be stacked.
 **/
static int __all_isr_count;
static int __os_isr_count;

void AUTOSAR_SuspendAllInterrupts() {
	debug_core << __FUNCTION__ << endl;
	Machine::disable_interrupts();
	__all_isr_count++;
}

void AUTOSAR_ResumeAllInterrupts() {
	debug_core << __FUNCTION__ << endl;
	__all_isr_count--;
	if (__all_isr_count == 0 && __os_isr_count == 0) {
		Machine::enable_interrupts();
	}
}

void AUTOSAR_SuspendOSInterrupts() {
	debug_core << __FUNCTION__ << endl;
	Machine::disable_interrupts();
	__os_isr_count++;
}

void AUTOSAR_ResumeOSInterrupts() {
	debug_core << __FUNCTION__ << endl;
	__os_isr_count--;
	if (__os_isr_count == 0 && __all_isr_count == 0) {
		Machine::enable_interrupts();
	}
}
