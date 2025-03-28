/**
 * Config file for testsuit benchmarks, defines different values for paramaters that describe the size and the properties of the system.
 * Only one variant can be active at the same time, set by meson.
 */

/**
 ******************** Variants ********************
 CYCLES: Number of times the schedueler runs, each cycles represents once the SCHEDUL_INTERVAL
 NUMBER_OF_RUNNABLES: Number of runnables that gets distributed acording to the percentages in RUNABLES_SHARE
 NUMBER_OF_LABELS: Number of all labels on the system, each is AVAERAGE_LABEL_SIZE big
 AVAERAGE_LABEL_SIZE: Size of a single label in Byte, calculated by (1*35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2)/ 100 -> 2.66 Byte
 */


// Lower border from paper
#if defined(VARIANT_BASIC)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

// Upper border from paper
#elif defined(VARIANT_LARGE)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNNABLES = 2000;
    constexpr unsigned NUMBER_OF_LABELS = 25000;

// to match our systems size
#elif defined(VARIANT_TINY)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNNABLES = 100;
    constexpr unsigned NUMBER_OF_LABELS = 5000;

// same as basic, but with longer runtime
#elif defined(VARIANT_LONG)
    constexpr unsigned CYCLES = 2020;
    constexpr unsigned NUMBER_OF_RUNNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

#elif defined(VARIANT_CUSTOM)
    constexpr unsigned CYCLES = 30;
    constexpr unsigned NUMBER_OF_RUNNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

// to make linter happier
#else
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 1000;

#endif

/**
 ******************** Static Variables ********************
 from Paper: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

// How long the software scheduler takes at least, before starting the next round of runnables
// Needs to match cycletime inside system.json alarm!
constexpr unsigned SCHEDUL_INTERVAL = 1000; //um -> 1000us = 1ms
// TODO TMP
//constexpr unsigned SCHEDUL_INTERVAL = 10000; //um -> 1000us = 1ms

// 10 activation periods, which gets grouped into a task each. From 1ms to 1000ms
constexpr unsigned NR_TASKS = 10;
// Angle Sync Values, assume the worst case, so the shortest period. So a bit car with 8 Cylinders and 5000 rpm
constexpr unsigned CYLINDERS = 8;
constexpr unsigned RPM = 5000;
// Formular is 60/(CYLINDERS*RPM) -> then convert into s (*60) -> then into milliseconds * 1000
constexpr unsigned ANGLE_SYNC_PERIOD = (1000*60*60)/(CYLINDERS * RPM);

// Name of each task
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000", "MSANGLE"};
enum task_id { MS1_id = 0, MS2_id = 1, MS5_id = 2, MS10_id = 3, MS20_id = 4, MS50_id = 5, MS100_id = 6, MS200_id = 7, MS1000_id = 8, MSANGLE_id = 9, MS_LAST_id = 10};
// Percentage share of each activation period of the total NUMBER_OF_RUNNABLES
constexpr unsigned RUNABLES_SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4, 15};
// Given activation periods in which runnables get triggered (in millisecond/ms)
constexpr unsigned RUNABLES_PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000, ANGLE_SYNC_PERIOD};   // TODO could modify slightly to decrease spike at multiples

// Factor by which the calculation of each task is split into
constexpr unsigned SPLITTIMES = 10;
constexpr unsigned SPLIT_PER_TASK[NR_TASKS] = {
	SPLITTIMES * RUNABLES_PERIOD[MS1_id],
	SPLITTIMES * RUNABLES_PERIOD[MS2_id],
	SPLITTIMES * RUNABLES_PERIOD[MS5_id],
	SPLITTIMES * RUNABLES_PERIOD[MS10_id],
	SPLITTIMES * RUNABLES_PERIOD[MS20_id],
	SPLITTIMES * RUNABLES_PERIOD[MS50_id],
	SPLITTIMES * RUNABLES_PERIOD[MS100_id],
	SPLITTIMES * RUNABLES_PERIOD[MS200_id],
	SPLITTIMES * RUNABLES_PERIOD[MS1000_id],
	SPLITTIMES * RUNABLES_PERIOD[MSANGLE_id],
};


// Average execution time of a single runnables in a specific activation period (in microseconds/us)
constexpr unsigned TIME_PER_RUNNABLE[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1, 7};
// Total runtime per task/periode

// constexpr unsigned TOTAL_RUNTIME[NR_TASKS] = {
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1_id] * TIME_PER_RUNNABLE[MS1_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS2_id] * TIME_PER_RUNNABLE[MS2_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS5_id] * TIME_PER_RUNNABLE[MS5_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS10_id] * TIME_PER_RUNNABLE[MS10_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS20_id] * TIME_PER_RUNNABLE[MS20_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS50_id] * TIME_PER_RUNNABLE[MS50_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS100_id] * TIME_PER_RUNNABLE[MS100_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS200_id] * TIME_PER_RUNNABLE[MS200_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1000_id] * TIME_PER_RUNNABLE[MS1000_id],
// 	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MSANGLE_id] * TIME_PER_RUNNABLE[MSANGLE_id]
// };


// for testing
// /*
constexpr unsigned TOTAL_RUNTIME[NR_TASKS] = {
	500,
	1500,
	1000,
	500,
	500,
	500,
	500,
	500,
	500,
	500
};
// */

// 90% of Labels are 1,2,4 Bytes, calculated average was 3 Bytes
constexpr unsigned AVAERAGE_LABEL_SIZE = 3;

// Of that: 40% read, 10% write, 50% read/write
constexpr unsigned READ_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 40 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
constexpr unsigned WRITE_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE* 10 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
constexpr unsigned RW_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 50 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
constexpr unsigned MEMORY_PER_RUNNABLE = READ_ACCESSES_PER_RUNNABLE + WRITE_ACCESSES_PER_RUNNABLE + RW_ACCESSES_PER_RUNNABLE;

uint8_t communication[NUMBER_OF_LABELS * AVAERAGE_LABEL_SIZE];
uint16_t memory_pos = 0;

// Final one is end of memory -> cant write further
constexpr unsigned memory_positions[NR_TASKS + 1] = {
	0,
	(NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1_id] * MEMORY_PER_RUNNABLE,
	memory_positions[1] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS2_id] * MEMORY_PER_RUNNABLE,
	memory_positions[2] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS5_id] * MEMORY_PER_RUNNABLE,
	memory_positions[3] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS10_id] * MEMORY_PER_RUNNABLE,
	memory_positions[4] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS20_id] * MEMORY_PER_RUNNABLE,
	memory_positions[5] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS50_id] * MEMORY_PER_RUNNABLE,
	memory_positions[6] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS100_id] * MEMORY_PER_RUNNABLE,
	memory_positions[7] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS200_id] * MEMORY_PER_RUNNABLE,
	memory_positions[8] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MS1000_id] * MEMORY_PER_RUNNABLE,
	memory_positions[9] + (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[MSANGLE_id] * MEMORY_PER_RUNNABLE
};

// InterTask Communication Patter
// with MS1 MS2 MS5 MS10 MS20 MS50 MS100 MS200 MS1000
// 0 = 0, I = 5, II = 25, III = 75, IV = 250, V = 750, VI = 1250
constexpr unsigned INTER_TASK_RATIO[NR_TASKS][NR_TASKS] = {
										{25, 0, 0, 5, 5, 0, 5, 0, 0, 5},
										{0, 25, 0, 5, 5, 0, 5, 0, 0, 0},
										{0, 5, 250, 250, 25, 25, 5, 0, 0, 0},
										{25, 25, 25, 1250, 250, 25, 250, 25, 75, 250},
										{5, 5, 5, 250, 1250, 25, 250, 5, 25, 250},
										{0, 0, 25, 25, 25, 75, 5, 0, 0, 0},
										{0, 5, 5, 750, 250, 25, 1250, 25, 75, 250},
										{0, 0, 0, 5, 5, 0, 5, 5, 5, 0},
										{0, 0, 0, 75, 25, 0, 75, 5, 250, 5},
										{5, 5, 5, 250, 250, 5, 75, 5, 5, 750}
										};


// Used the reduce the number o task, removing the ones with the longest scheduling intervals
// With all tasks the analysis might take very long!
constexpr unsigned TASK_COUNT = 3;
static_assert(TASK_COUNT <= NR_TASKS);


constexpr unsigned WARMUP = 10;
constexpr unsigned COOLDOWN = CYCLES - 10;

/**
 ******************** Debug Helpers ********************
 */

void kout_run_info() {

	#if defined(VARIANT_BASIC)
		kout << "VARIANT_BASIC" << endl;
	#elif defined(VARIANT_LARGE)
		kout << "VARIANT_LARGE" << endl;
	#elif defined(VARIANT_TINY)
		kout << "VARIANT_TINY" << endl;
	#elif defined(VARIANT_LONG)
		kout << "VARIANT_LONG" << endl;
	#else
		kout << "VARIANT_UNKNOWN" << endl;
	#endif

    kout << "#CYCLES    : " << CYCLES << endl;
    kout << "#RUNNABLES : " << NUMBER_OF_RUNNABLES << endl;
    kout << "#LABELS    : " << NUMBER_OF_LABELS << " (if simulated)" << endl;
    kout << "\n*******************\n" << endl;

}

/*
TASK     | NUMBER OF RUNNABLES | EXPECTED RUNTIME | EXPECTED RUNTIME per SCHEDUL_INTERVAL
------------------------------------------------
MS1             | 30x           | 150 us          | 150 us
MS2             | 20x           | 100 us
MS5             | 20x           | 240 us
MS10            | 250x          | 2750 us
MS20            | 250x          | 2250 us
MS50            | 30x           | 540 us
MS100           | 200x          | 2200 us
MS200           | 10x           | 30 us
MS1000          | 40x           | 40 us
MSANGLE         | 150x          | 1050 us
Total number of runnables = 1000				
Avarage runtime per Scheduling interval = 600 us -> 60%

EXPECTED RUNTIME / RUNABLES_PERIOD[NR_TASKS]
Cylcles
*/
void kout_task_data() {
	unsigned exp_runtime = 0;
	unsigned runables = 0;
	unsigned rt_si = 0;
	kout << "Runnables + Runtime Table with " << TASK_COUNT << " tasks:" << endl;
	kout << "TASK     | NUMBER OF RUNNABLES | EXPECTED RUNTIME | EXPECTED RUNTIME per SCHEDUL_INTERVAL" << endl;
	kout << "------------------------------------------------" << endl;
	for (unsigned i = 0; i < TASK_COUNT; i++) {
		runables += (NUMBER_OF_RUNNABLES / 100) * RUNABLES_SHARE[i];
		exp_runtime = TOTAL_RUNTIME[i];
		rt_si += exp_runtime / RUNABLES_PERIOD[i];
		kout << taskStrings[i] << "\t | " << (NUMBER_OF_RUNNABLES / 100) * RUNABLES_SHARE[i] << "\t\t\t| ";
		kout << exp_runtime << "\tus";
		kout << "\t  | " << exp_runtime / RUNABLES_PERIOD[i] << "\tus" << endl;
	}
	kout << "Active number of runnables=" << runables << "  |  Total runtime per interval=" << rt_si << endl;
}

void kout_intercom_data() {

	kout << "\nInter-Task Communication Matrix\nLeft column is sender, the others are receiving tasks" << endl;
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout <<  taskStrings[i] << "\t";
	}
	kout << "\n-------------------------------------------------------------------------" << endl;
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout << taskStrings[i] << "\t";
		for (unsigned j = 0; j < NR_TASKS; j++) {
			kout << INTER_TASK_RATIO[i][j] << "\t";
		}
		kout << endl;
	}
	kout << endl;
	
}
	