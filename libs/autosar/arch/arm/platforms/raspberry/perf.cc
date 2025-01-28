// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "perf.h"
#include "platform.h"

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

// think there is a bug with small numbers! TODO
extern "C" bool cycles_wait_starttime(uint32_t starttime, uint32_t wait_time) {
	
	uint32_t endtime = starttime + wait_time;
	uint32_t currenttime = arch::Perf::get_cycles();

	// check if waiting is needed
	// no overflow -> simple
	if (starttime < endtime) {	
		if (currenttime > endtime) {
			return false;
		}
	}
	// endtime overflowed, need to check that current overflowed aswell
	else {
		if (currenttime > endtime && currenttime < starttime) {
			return false;
		}
	}
	

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
	
	return true;
	// kout << "Done, get_cycles: " << arch::Perf::get_cycles() << endl;

}


/**
 * Wait for wait_time microseconds minus the time that passed after measuring start_time
 * @param start_time cycles, measured by arch::Perf::get_cycles()
 * @param wait_time time in microseconds, for what should be waited 
 * @return true if waiting happend, or false if waiting window was already over
 *  */
extern "C" bool micro_sec_wait_upto(uint32_t start_time, uint32_t wait_time) {
	
	return cycles_wait_starttime(start_time, WAIT_FREQUENCE * wait_time);

}

/**
 * Wrapper for micro_sec_wait to be included by ara_timing_info.
 * ALWAYS uses the bcet!
 * */
extern "C" void bcet_micro_sec_wait(int bcet, int wcet) {

		if (bcet == 0)
			return;
		micro_sec_wait(bcet);
}

/*
* Wait for wait_time microseconds, 
* maxTime on Pi is 		17.1s = 17 100 000 us
* maxTime with Qemu is  4.3s  = 4 300 000 us
*/
extern "C" void micro_sec_wait(uint32_t wait_time) {
	
	cycles_wait(WAIT_FREQUENCE * wait_time);
}

