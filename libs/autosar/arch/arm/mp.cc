// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "arch/generic/hardware_threads.h"
#include "gic.h"
#include "machine.h"
#include "mmu.h"
#include "os.h"
#include "output.h"

extern "C" int main(void);

_Atomic(int) cores = 1;
_Atomic(int) syncing_cores[arch::SYNC_MAX] = {0};
_Atomic(bool) ipi_cleared[MAX_CPUS];

namespace arch {

	int get_cpuid() {
		/* This cannot be done from EL0 where syscalls are running
		int ret;
		asm volatile(
		    "mrc p15, 0, %[ret], c0, c0, 5;"   // cpuid to r0
		    "and %[ret], %[ret], #0xf;"         // mask
		:[ret] "=r" (ret)
		::
		);
		return ret;*/

		int reg_value;
		asm("mov %0, r9" : "=r"(reg_value));
		return reg_value;
	}

	unsigned int get_num_cores() { return cores; }

	void sync_all_hardware_threads(cpu_sync_point_t sync_point) {
		int synced = ++syncing_cores[sync_point];
		// debug_core << "Syncing[" << sync_point << "]: " << synced << "/" << cores << endl;

		// wait until all cores have synced
		while (syncing_cores[sync_point] < cores)
			;
	}

	void stop_hardware_thread() {
		Machine::disable_interrupts();

		/* sync all cores before machine shutdown */
		arch::sync_all_hardware_threads(arch::SYNC_POST_SHUTDOWNHOOK);

		while (1) {
			Machine::reset();
		}
	}

	void stop_other_hardware_threads() {
		if (cores > 1) {
			GIC::trigger_others(12);
		}
	}

	extern "C" void* start_hardware_thread_stage2(int hardware_number) {
		MMU::enable();

		cores++;
		main();
	}

	StatusType start_hardware_thread(unsigned int hardware_number, void* bottom_of_stack, unsigned int size_of_stack) {
		if (hardware_number >= 4)
			return E_NOT_OK;

		// LOCAL address and Maibox offset per CPU
		uint32_t addr = 0xff800000 + 0x8c + hardware_number * 0x10;
		asm volatile("ldr r0,=%[label];" // target label to r0
		             "str r0,[%0];"      // store r0 to precalculated address
		             "sev;" ::"r"(addr),
		             [label] "X"(start_hardware_thread_stage2)
		             : "r0");

		return E_OK;
	}

} // namespace arch
