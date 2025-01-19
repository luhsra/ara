// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "arch/generic/hardware_threads.h"
#include "machine.h"
#include "os.h"
#include "output.h"
#include "boot_cpu.h"

extern "C" int main(void);

_Atomic(int) cores = 1;
_Atomic(int) syncing_cores[arch::SYNC_MAX] = {0};
_Atomic(bool) ipi_cleared[MAX_CPUS];
_Atomic(bool) core_is_ready[MAX_CPUS] = {false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false};


namespace arch {
	

	hls_t hart_local_storage[MAX_HARTS];

	int get_cpuid() {
		//return the id of the current core
		uint32_t hartid;
		asm volatile("csrr %0, mhartid" : "=r" (hartid) );

		return hartid - BOOT_CORE;		
	}

	unsigned int get_num_cores() { 
		return cores;
	}

	void sync_all_hardware_threads(cpu_sync_point_t sync_point) {
		
		int synced = ++syncing_cores[sync_point];
		debug_core << "Syncing[" << sync_point << "] with core: " << get_cpuid() << " : " << synced << "/" << cores << endl;
		//kout << synced << endl;

		//debug_core << "Cores Ready: " <<  core_is_ready[0] << ", "<< core_is_ready[1] << ", "<< core_is_ready[2] << ", "<< core_is_ready[3] << ", "<< core_is_ready[4] << endl; 

		// wait until all cores have synced
		while (syncing_cores[sync_point] < cores)
			;
			
	}

	void stop_hardware_thread() {
		Machine::disable_interrupts();

		/* sync all cores before machine shutdown */
		arch::sync_all_hardware_threads(arch::SYNC_POST_SHUTDOWNHOOK);

		debug_core << "Stopping core: " << get_cpuid() << endl;

		if (arch::get_cpuid() == 0) {
			Machine::shutdown();
			Machine::unreachable();
		} else {
			while (1) {
				Machine::nop();
				//kout << "Trapped" << endl;
			}
		}
	}

	void stop_other_hardware_threads() {
		debug_core << "Stopping other cores" << endl;
		if (cores > 1) {
			int curr_cpuid = get_cpuid();
			for (int i = 0; i < MAX_CPUS; i++) {
				if (i == curr_cpuid)
					continue;
				if(core_is_ready[i]){
					Machine::trigger_interrupt(12, i, false);
					core_is_ready[i] = false;
				}
			}
		}
	}

	StatusType start_hardware_thread(unsigned int hardware_number, void* bottom_of_stack, unsigned int size_of_stack) {
		//kout << "Start hardware threat" << hardware_number << endl;

		core_is_ready[hardware_number] = true;
		cores++;
		return E_OK;
	}

} // namespace arch
