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