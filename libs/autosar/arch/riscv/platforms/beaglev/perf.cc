#include "perf.h"

uint64_t arch::Perf::cycles[MAX_TRACES] = {0};
uint64_t arch::Perf::cycles_nr = 0;
uint64_t arch::Perf::counter0[MAX_TRACES] = {0};
uint64_t arch::Perf::counter0_nr = 0;

// b currently unused, but required due to parameter signature for generator
extern "C" void wait(int a, int b) { 
	if (a == 0) return;
    int counter = 0;
	unsigned int starttime = arch::Perf::get_cycles();
	const int cycle_resolution = 1000; // cycles per unit of a
	unsigned int endtime = starttime + a*cycle_resolution;
	//kout << "waiting for " << a*cycle_resolution << " cycles" << endl;
    while (endtime >= arch::Perf::get_cycles()) {
        counter++;
    };
};

extern "C" bool cycles_wait_starttime(uint64_t starttime, uint64_t wait_time) {
	
	uint64_t endtime = starttime + wait_time;
	uint64_t currenttime = arch::Perf::get_cycles();

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
	else if (endtime > 0xFFFF000000000000) {
		endtime = 0xFFFF000000000000;
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

extern "C" void cycles_wait(uint64_t wait_time) {
	
	uint64_t starttime = arch::Perf::get_cycles();
	uint64_t endtime = starttime + wait_time;

	
	// the comparison happens not at every cycle, therefore the overflow cases might be skipped
	if (endtime < 0x0000FFFF) {
		endtime = 0x0000FFFF;
	}
	else if (endtime > 0xFFFF000000000000) {
		endtime = 0xFFFF000000000000;
	}

	// kout << (hex) << "Wait_time: " <<  wait_time << " start: " << starttime << " end: " << endtime << endl;

	// no overflow happens
	if (starttime < endtime) {
		while (arch::Perf::get_cycles() <= endtime) {
			// kout << "A:" << arch::Perf::get_cycles() << endl;
		};
	// overflow happend
	} else if (starttime > endtime) {

		// wait until overflow happend back to 0
		while (arch::Perf::get_cycles() >= endtime) {
			// kout << "B:" << arch::Perf::get_cycles() << endl;

		};

		// then wait until cycles is above endtime
		while (arch::Perf::get_cycles() <= endtime) {
			// kout << "C:" << arch::Perf::get_cycles() << endl;
		};
	}

	// kout << "Done, get_cycles: " << arch::Perf::get_cycles() << endl;

}

extern "C" void micro_sec_wait(uint64_t wait_time) {
	cycles_wait(WAIT_FREQUENCE * wait_time);
}

extern "C" void cycles_wait_dynamic_endtime(uint64_t wait_time, uint64_t* endtime_pointer) {
	
	uint64_t starttime = arch::Perf::get_cycles();
	*endtime_pointer = starttime + wait_time;

	// the comparison happens not at every cycle, therefore the overflow cases might be skipped
	if (*endtime_pointer < 0x0000FFFF) {
		*endtime_pointer = 0x0000FFFF;
	}
	else if (*endtime_pointer > 0xFFFF000000000000) {
		*endtime_pointer = 0xFFFF000000000000;
	}

	// kout << (hex) << "Wait_time: " <<  wait_time << " start: " << starttime << " end: " << *endtime_pointer << endl;

	// no overflow happens
	if (starttime < *endtime_pointer) {
		while (arch::Perf::get_cycles() <= *endtime_pointer) {

		};
	// overflow happend
	} else if (starttime > *endtime_pointer) {

		// wait until overflow happend back to 0
		while (arch::Perf::get_cycles() >= *endtime_pointer) {

		};

		// then wait until cycles is above endtime
		while (arch::Perf::get_cycles() <= *endtime_pointer) {

		};
	}

	// kout << "Done, get_cycles: " << arch::Perf::get_cycles()<< " *endtime_pointer: " << *endtime_pointer << endl;
	*endtime_pointer = 0;

}

extern "C" bool micro_sec_wait_upto(uint64_t start_time, uint64_t wait_time) {
	
	return cycles_wait_starttime(start_time, WAIT_FREQUENCE * wait_time);

}
extern "C" void micro_sec_wait_end_time(uint64_t wait_time, uint64_t* end_time) {
	// kout << "w*: " << WAIT_FREQUENCE * wait_time << "w: " << wait_time << "e: " << end_time << "*e: " << *end_time << endl;
	cycles_wait_dynamic_endtime(WAIT_FREQUENCE * wait_time, end_time);
}