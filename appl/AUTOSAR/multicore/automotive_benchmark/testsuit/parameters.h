/**
 * Config file for testsuit benchmarks, defines different values for paramaters that describe the size and the properties of the system.
 * Only one variant can be active at the same time, set by meson.
 */


/**
 ******************** Static Variables ********************
 from Paper: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

// How long the software scheduler takes at least, before starting the next round of runnables
const unsigned SCHEDUL_INTERVAL = 1000; //um -> 1000us = 1ms

// 9 activation periods, which gets grouped into a task each. From 1ms to 1000ms, TODO add angly-sync period
const unsigned NR_TASKS = 9;
// Name of each 
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000"};
enum task_id { MS1_id = 0, MS2_id = 1, MS5_id = 2, MS10_id = 3, MS20_id = 4, MS50_id = 5, MS100_id = 6, MS200_id = 7, MS1000_id = 8, MS_LAST_id = 9};
// Percentage share of each activation period of the total NUMBER_OF_RUNNABLES
const unsigned RUNABLES_SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4};
// Given activation periods in which runnables get triggered (in millisecond/ms)
const unsigned RUNABLES_PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};   // TODO could modify slightly to decrease spike at multiples
// Average execution time of a single runnables in a specific activation period (in microseconds/us)
const unsigned TIME_PER_RUNNABLE[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1};

/**
 ******************** Variants ********************
 CYCLES: Number of times the schedueler runs, each cycles represents once the SCHEDUL_INTERVAL
 NUMBER_OF_RUNNABLES: Number of runnables that gets distributed acording to the percentages in RUNABLES_SHARE
 */

// Upper border from paper
#if VARIANT_LARGE
const unsigned CYCLES = 1000;
const unsigned NUMBER_OF_RUNNABLES = 1500;
const unsigned NUMBER_OF_LABELS = 25000;

// Lower border from paper
#elif VARIANT_SMALL
const unsigned CYCLES = 1000;
const unsigned NUMBER_OF_RUNNABLES = 1000;
const unsigned NUMBER_OF_LABELS = 10000;

// same as small, but with longer runtime
#elif VARIANT_LONG
const unsigned CYCLES = 5000;
const unsigned NUMBER_OF_RUNNABLES = 1000;
const unsigned NUMBER_OF_LABELS = 10000;

// Default fallback case
#else
const unsigned CYCLES = 1000;
const unsigned NUMBER_OF_RUNNABLES = 1000;
const unsigned NUMBER_OF_LABELS = 10000;
#endif


/**
 ******************** Debug Helpers ********************
 */

void kout_run_info() {

    kout << "#CYCLES    : " << CYCLES << endl;
    kout << "#RUNNABLES : " << NUMBER_OF_RUNNABLES << endl;
    kout << "#LABELS    : " << NUMBER_OF_LABELS << endl;
    kout << "\n*******************\n" << endl;

}

void kout_static_data() {

	kout << "\n\nTASK     | NUMBER OF RUNNABLES | EXPECTED RUNTIME" << endl;
	kout << "---------------------------------------------" << endl;
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout << taskStrings[i] << "\t\t| " << (NUMBER_OF_RUNNABLES / 100) * RUNABLES_SHARE[i] << "x \t\t| " << (NUMBER_OF_RUNNABLES / 100) * RUNABLES_SHARE[i] * TIME_PER_RUNNABLE[i] << " us" << endl;
	}
}
