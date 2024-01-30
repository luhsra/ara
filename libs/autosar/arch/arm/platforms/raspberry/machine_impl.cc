// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup ARM
 * @brief Reset operation
 */

#include "gic.h"
#include "machine.h"
#include "platform.h"

extern "C" uint32_t GET32(uint32_t Addr) { return *(volatile uint32_t*)Addr; }

extern "C" void PUT32(uint32_t OutAddress, uint32_t Value) { *(volatile uint32_t*)OutAddress = Value; }

void Machine::reset(void) {
	unsigned int pm_rstc, pm_wdog, timeout;
	timeout = 1000;

	pm_rstc = GET32(PM_RSTC);
	pm_wdog = PM_PASSWORD | (timeout & PM_WDOG_TIME_SET);
	pm_rstc = PM_PASSWORD | (pm_rstc & PM_RSTC_WRCFG_CLR) | PM_RSTC_WRCFG_FULL_RESET;
	PUT32(PM_WDOG, pm_wdog);
	PUT32(PM_RSTC, pm_rstc);

	arch::GIC::set_task_prio(0); // pause interrupts
	Machine::halt();
}

// L2 cache
#define L2CACHE_SIZE (1 << 20) // Size of L2 cache in bytes
#define L2CACHE_LINE_SIZE 64   // Size of a L2 cache line

void Machine::setup_caches(void) {
	int addr;
	// invalidate dcache
	for (addr = (uint32_t)0; addr < (L2CACHE_SIZE); addr += L2CACHE_LINE_SIZE) {
		asm volatile("mcr p15, 0, %0, c7, c6, 1 \n\r" /* Invalidate Data or Unified cache line by MVA to PoU */
		             "nop;" ::"r"(addr)
		             :);
	}
}