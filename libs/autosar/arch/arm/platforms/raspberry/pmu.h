// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include "inline.h"
#include "output.h"

#define PMCR_ENABLE (1 << 0)
#define PMCR_RESET_ALL (1 << 1)
#define PMCR_RESET_CYCLE (1 << 2)
#define PMCR_DIVIDER (1 << 3)

#define PMCR_SETUP (PMCR_ENABLE | PMCR_RESET_ALL | PMCR_RESET_CYCLE)

// https://developer.arm.com/documentation/100095/0003/Performance-Monitor-Unit/Events
#define CPU_CYCLES 0x11
#define L2D_CACHE_REFILL 0x17
#define L2D_CACHE_REFILL_LD 0x52

#define MAX_TRACES 64

namespace arch {
	class PMU {
		static int cycles[MAX_TRACES];
		static int cycles_nr;

		static int counter0[MAX_TRACES];
		static int counter0_nr;

	  public:
		static forceinline void start() {

			// Performance Monitor Control Register (PMCR) : initialize
			asm volatile("MCR p15, 0, %0, c9, c12, 0\t\n" ::"r"(PMCR_SETUP));

			// Overflow Flag Status Register (PMOVSR) : reset
			asm volatile("MCR p15, 0, %0, c9, c12, 3\t\n" ::"r"(0x8000000f));

			// Event Counter Selection Register (PMSELR) : counter 0
			asm volatile("MCR p15, 0, %0, c9, c12, 5\t\n" ::"r"(0));

			// Event Type Select Register (PMXEVTYPER)
			asm volatile("MCR p15, 0, %0, c9, c13, 1\t\n" ::"r"(L2D_CACHE_REFILL));

			// Count Enable Set Register (PMCNTENSET)
			asm volatile("MCR p15, 0, %0, c9, c12, 1\t\n" ::"r"(0x8000000f));
		}

		static forceinline void reset() {
			// Performance Monitor Control Register (PMCR) : initialize
			asm volatile("MCR p15, 0, %0, c9, c12, 0\t\n" ::"r"(PMCR_SETUP));
			// debug_core << "reset" << endl;
		}

		static forceinline void trace_cycles() {
			unsigned int output;
			// Cycle Count Register (PMCCNTR) : read
			asm volatile("MRC p15, 0, %0, c9, c13, 0 \t\n" : "=r"(output));
			cycles[cycles_nr++] = output;
		}

		static forceinline unsigned int get_cycles() {
			unsigned int output;
			// Cycle Count Register (PMCCNTR) : read
			asm volatile("MRC p15, 0, %0, c9, c13, 0 \t\n" : "=r"(output));
			return output;
		}

		static forceinline void trace_counter0() {
			unsigned int output;
			// Event Count Register (PMXEVCNTR) : read
			asm volatile("MRC p15, 0, %0, c9, c13, 2 \t\n" : "=r"(output));
			counter0[counter0_nr++] = output;
		}

		static forceinline void stop() {
			// Count Enable Clear Register (PMCNTENCLR)
			asm volatile("MCR p15, 0, %0, c9, c12, 2\t\n" ::"r"(0x8000000f));
		}

		static forceinline void reset_counters() {
			cycles_nr = 0;
			counter0_nr = 0;
		}

		static void print_cycles() {
			for (int i = 0; i < cycles_nr; i++) {
				// print cycles
				kout << "val[" << i << "]=" << cycles[i] << endl;
			}
			for (int i = 1; i < cycles_nr; i++) {
				// print diff
				kout << "d[" << i - 1 << ">" << i << "]=" << cycles[i] - cycles[i - 1] << endl;
			}
		}
		static void print_counter0() {
			for (int i = 0; i < counter0_nr; i++) {
				// print cycles
				kout << "val[" << i << "]=" << counter0[i] << endl;
			}
			for (int i = 1; i < counter0_nr; i++) {
				// print diff
				kout << "d[" << i - 1 << ">" << i << "]=" << counter0[i] - counter0[i - 1] << endl;
			}
		}
	};
} // namespace arch