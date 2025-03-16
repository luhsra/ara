#include "perf.h"

int arch::Perf::cycles[MAX_TRACES] = {0};
int arch::Perf::cycles_nr = 0;
int arch::Perf::counter0[MAX_TRACES] = {0};
int arch::Perf::counter0_nr = 0;

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