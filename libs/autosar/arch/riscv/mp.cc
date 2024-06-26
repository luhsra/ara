// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "arch/generic/hardware_threads.h"
#include "machine.h"
#include "os.h"
#include "output.h"

extern "C" int main(void);

_Atomic(int) cores = 1;
_Atomic(int) syncing_cores[arch::SYNC_MAX] = {0};
_Atomic(bool) ipi_cleared[MAX_CPUS];
_Atomic(bool) core_is_ready[MAX_CPUS] = {false};


namespace arch {
	

	hls_t hart_local_storage[MAX_HARTS];

	int get_cpuid() {
		//return the id of the current core

		uint32_t x;
		asm volatile("csrr %0, mhartid" : "=r" (x) );
	
		return x;
	}

	unsigned int get_num_cores() { 
		return cores;
	}

	void sync_all_hardware_threads(cpu_sync_point_t sync_point) {
		
		int synced = ++syncing_cores[sync_point];
		debug_core << "Syncing[" << sync_point << "]: " << synced << "/" << cores << endl;

		// wait until all cores have synced
		while (syncing_cores[sync_point] < cores)
			;
			
	}

	void stop_hardware_thread() {
		Machine::disable_interrupts();

		/* sync all cores before machine shutdown */
		arch::sync_all_hardware_threads(arch::SYNC_POST_SHUTDOWNHOOK);

		if (arch::get_cpuid() == 0) {
			Machine::shutdown();
			Machine::unreachable();
		} else {
			while (1) {
				Machine::nop();
			}
		}
	}

	void stop_other_hardware_threads() {
		/*
		if (cores > 1) {
			GIC::trigger_others(12);
		}
		*/
	}

	extern "C" void* start_hardware_thread_stage2(int hardware_number) {
		/*
		MMU::enable();

		cores++;
		main();
		*/
	}

	StatusType start_hardware_thread(unsigned int hardware_number, void* bottom_of_stack, unsigned int size_of_stack) {
		//set flag to indicate that the core is online


		core_is_ready[hardware_number] = true;
		cores++;
		/*
		

		// LOCAL address and Maibox offset per CPU
		uint32_t addr = 0xff800000 + 0x8c + hardware_number * 0x10;
		asm volatile("ldr r0,=%[label];" // target label to r0
		             "str r0,[%0];"      // store r0 to precalculated address
		             "sev;" ::"r"(addr),
		             [label] "X"(start_hardware_thread_stage2)
		             : "r0");
		*/

		return E_OK;
	}

} // namespace arch
