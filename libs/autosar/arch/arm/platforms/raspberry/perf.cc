// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "perf.h"

int arch::Perf::cycles[MAX_TRACES] = {0};
int arch::Perf::cycles_nr = 0;
int arch::Perf::counter0[MAX_TRACES] = {0};
int arch::Perf::counter0_nr = 0;

extern "C" void wait(int a, int b){
	int counter = 0;
	if (a == 0) return;
	uint32_t starttime = arch::Perf::get_cycles();
	const int time_resolution = 1000; // clocks per time unit
	uint32_t endtime = starttime + a*time_resolution;
	//kout << "waiting for " << a*time_resolution << " cycles" << endl;

	// wait for at least BCET, assuming 1*time_resolution is already caclulated for, because of system call
	/*volatile int c;
	if (a == 60) { //for running_pmu T02
		while (counter < 6661) {
			c = arch::PMU::get_cycles();
			counter++;
		}
	} else {*/
		while (endtime >= arch::Perf::get_cycles()) {
			counter++;
		};
	//}
};

/*
* Wait for wait_time cpu cycles, measured by arch::Perf,
* maxValue is 0xFFFF FFFF / 4 294 967 295
*/
extern "C" void cycles_wait(uint32_t wait_time) {
	
	// if (wait_time == 0) return;
	uint32_t starttime = arch::Perf::get_cycles();
	uint32_t endtime = starttime + wait_time;

	// the comparison happens not at every cycle, therefore the overflow cases might be skipped
	if (endtime < 0x0000FFFF) {
		endtime = 0x0000FFFF;
	}
	else if (endtime > 0xFFFF0000) {
		endtime = 0xFFFF0000;
	}

	// kout << (hex) << "Wait_time: " <<  wait_time << " start: " << starttime << " end: " << endtime << endl;

	// no overflow happens
	if (starttime < endtime) {
		while (arch::Perf::get_cycles() <= endtime) {

		};
	// overflow happend
	} else if (starttime > endtime) {

		// wait until overflow happend back to 0
		while (arch::Perf::get_cycles() >= endtime) {

		};

		// then wait until cycles is above endtime
		while (arch::Perf::get_cycles() <= endtime) {

		};
	}

	// kout << "Done, get_cycles: " << arch::Perf::get_cycles() << endl;

}


// somehow cant calulate MEASURED_CYCLES * X, when using #define
/* 
	kout << "MEASURED_CYCLES: " << MEASURED_CYCLES << endl;
	kout << "time*MEASURED_CYCLES: " << wait_time * MEASURED_CYCLES << endl;
	kout << "time*TMP_MEASURED: " << wait_time * TMP_MEASURED << endl;
*/
uint32_t const MAX_UINT_32 = 0xFFFFFFFF;
// measured time in microsecond that qemu took to wait for 0xFFFFFFFF cycles -> ~5.6s
uint32_t measured_time_micro_s = 5600000;
// calculated number of cpu cycles for arround 1 microsecond -> 766
uint32_t measured_cycles_qemu = MAX_UINT_32/measured_time_micro_s;
// pi runs with 250 MHz
uint32_t cycles_pi = 250;


/*
* Wait for wait_time microseconds, 
* maxTime is 5 600 000 micro-s / 5.6s
* precision depends
*/
extern "C" void micro_sec_wait(uint32_t wait_time) {

	// cycles_wait(wait_time * measured_cycles_qemu);
	cycles_wait(wait_time * cycles_pi);
}

