// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * Config file for testsuit benchmarks, defines different values for paramaters that describe the size and the properties of the system.
 * Only one variant can be active at the same time, set by meson.
 */

/**
 ******************** Variants ********************
 CYCLES
 Number of times the schedueler is called, each cycles represents once the SCHEDUL_INTERVAL

 NUMBER_OF_RUNABLES
 Number of runnables that gets distributed acording to the percentages in RUNABLES_SHARE
 -> main option to modify systems load

 NUMBER_OF_LABELS
 Number of all labels on the system, each is AVAERAGE_LABEL_SIZE big
 -> modify impact of memory operation (ignored if memory memory is not measured)
 */

// Lower border from paper
#if defined(VARIANT_BASIC)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

// Upper border from paper
#elif defined(VARIANT_LARGE)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNABLES = 2000;
    constexpr unsigned NUMBER_OF_LABELS = 25000;

// to match our systems size
#elif defined(VARIANT_TINY)
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNABLES = 100;
    constexpr unsigned NUMBER_OF_LABELS = 5000;

// same as basic, but with longer runtime
#elif defined(VARIANT_LONG)
    constexpr unsigned CYCLES = 2020;
    constexpr unsigned NUMBER_OF_RUNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

#elif defined(VARIANT_CUSTOM)
    constexpr unsigned CYCLES = 80;
    constexpr unsigned NUMBER_OF_RUNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 10000;

// to make linter happier
#else
    constexpr unsigned CYCLES = 1020;
    constexpr unsigned NUMBER_OF_RUNABLES = 1000;
    constexpr unsigned NUMBER_OF_LABELS = 1000;

#endif
// Cycles ignored at the start.
constexpr unsigned WARMUP = 10;
// Cycles at the end, where no new tasks are started but running ones can finish.
constexpr unsigned COOLDOWN = CYCLES - 10;

constexpr unsigned COUNTED_CYCLES = COOLDOWN- WARMUP;
/**
 ******************** DEFINEs ********************
 * Control what gets measured and printed at the end, comment in or out.
 */

// At start of run print variant and its values
// #define PRINT_VARIANT

// At end of run print stats about the runned tasks
// #define PRINT_TASK_DATA

// At end of run print how often each task completed or got blocked because the previous run was still running
// #define PRINT_RUN_STATS

// At end of run print time spend between each call of TASK(SCHED), should be equal to SCHEDUL_INTERVAL
// #define PRINT_CYCLE_TIMING

// At end of run print time that passed between start and end of each run of each task
// #define PRINT_TASK_TIMING

// At end of run print time spend in hooks
// #define PRINT_HOOK_STATS

// At end of run print time spent idling
// #define PRINT_IDLE

// At end of run print memory setup
// #define PRINT_MEM_STATS

// prints the result for the automated benchmark
#define BENCHMARK



// Activate angle sync task
// #define ANGLE


/**
 ******************** Static Variables ********************
 from Paper: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */
// How long the software scheduler takes at least, before starting the next round of runnables
// Needs to match cycletime inside system.json alarm!
constexpr unsigned SCHEDUL_INTERVAL = 1000; //um -> 1000us = 1ms

// 10 activation periods, which gets grouped into a task each. From 1ms to 1000ms
constexpr unsigned NR_TASKS = 10;
// Used to reduce the number o task, removing the ones with the longest scheduling intervals.
// With all tasks the analysis might take very long!
// for 7 Tasks ~200s, for 8 Tasks 1340s
constexpr unsigned TASK_COUNT = 3;
static_assert(TASK_COUNT <= NR_TASKS);


// Name of each task
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000", "MSANGLE"};
enum task_id { MS1_id = 0, MS2_id = 1, MS5_id = 2, MS10_id = 3, MS20_id = 4, MS50_id = 5, MS100_id = 6, MS200_id = 7, MS1000_id = 8, MSANGLE_id = 9, MS_LAST_id = 10};

// Percentage share of each activation period of the total NUMBER_OF_RUNABLES
constexpr unsigned RUNABLES_SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4, 15};
// Given activation periods in which runnables get triggered (in millisecond/ms)
// Angle_sync task changes it period!
constexpr unsigned RUNABLES_PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000, 0};   // TODO could modify slightly to decrease spike at multiples
// Average execution time of a single runnables in a specific activation period (in microseconds/us)
constexpr unsigned TIME_PER_RUNABLE[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1, 7};
// Of how many runnables each tasks consist
constexpr unsigned RUNABLES_COUNT[NR_TASKS] = {
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS1_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS2_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS5_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS10_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS20_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS50_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS100_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS200_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MS1000_id],
	(NUMBER_OF_RUNABLES/100) * RUNABLES_SHARE[MSANGLE_id]
};
// Total runtime of each task
constexpr unsigned TOTAL_RUNTIME[NR_TASKS] = {
	RUNABLES_COUNT[MS1_id] * TIME_PER_RUNABLE[MS1_id],
	RUNABLES_COUNT[MS2_id] * TIME_PER_RUNABLE[MS2_id],
	RUNABLES_COUNT[MS5_id] * TIME_PER_RUNABLE[MS5_id],
	RUNABLES_COUNT[MS10_id] * TIME_PER_RUNABLE[MS10_id],
	RUNABLES_COUNT[MS20_id] * TIME_PER_RUNABLE[MS20_id],
	RUNABLES_COUNT[MS50_id] * TIME_PER_RUNABLE[MS50_id],
	RUNABLES_COUNT[MS100_id] * TIME_PER_RUNABLE[MS100_id],
	RUNABLES_COUNT[MS200_id] * TIME_PER_RUNABLE[MS200_id],
	RUNABLES_COUNT[MS1000_id] * TIME_PER_RUNABLE[MS1000_id],
	RUNABLES_COUNT[MSANGLE_id] * TIME_PER_RUNABLE[MSANGLE_id]
};
// Overwrite for testing
/*
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
*/

// [MEMORY]
// AVAERAGE_LABEL_SIZE: Size of a single label in Byte, calculated by (1*35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2)/ 100 -> 2.66 Byte
// 90% of Labels are 1,2,4 Bytes, calculated average was 3 Bytes
constexpr unsigned AVAERAGE_LABEL_SIZE = 3;
constexpr unsigned LABELS_PER_RUNABLE = NUMBER_OF_LABELS / NUMBER_OF_RUNABLES;

// Of that: 40% read, 10% write, 50% read/write
constexpr unsigned RO_SHARE = 40;
// constexpr unsigned WO_SHARE = 10;
constexpr unsigned RW_SHARE = 50;

constexpr unsigned RO_MEMORY = (NUMBER_OF_LABELS / 100) * RO_SHARE * AVAERAGE_LABEL_SIZE;
// constexpr unsigned WO_MEMORY = (NUMBER_OF_LABELS / 100) * WO_SHARE * AVAERAGE_LABEL_SIZE;
constexpr unsigned INTERCOM_MEMORY = (NUMBER_OF_LABELS / 100) * RW_SHARE * AVAERAGE_LABEL_SIZE;

constexpr unsigned ro_memory_size[NR_TASKS] = {
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
	(RO_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
};

// Final one is end of memory -> cant write further
constexpr unsigned ro_memory_offset[NR_TASKS + 1] = {
	0,
	ro_memory_offset[0] + ro_memory_size[MS1_id],
	ro_memory_offset[1] + ro_memory_size[MS2_id],
	ro_memory_offset[2] + ro_memory_size[MS5_id],
	ro_memory_offset[3] + ro_memory_size[MS10_id],
	ro_memory_offset[4] + ro_memory_size[MS20_id],
	ro_memory_offset[5] + ro_memory_size[MS50_id],
	ro_memory_offset[6] + ro_memory_size[MS100_id],
	ro_memory_offset[7] + ro_memory_size[MS200_id],
	ro_memory_offset[8] + ro_memory_size[MS1000_id],
	ro_memory_offset[9] + ro_memory_size[MSANGLE_id]
};

// Write only memory skipped for now, since it is only 10% and hard to measure.
// constexpr unsigned wo_memory_size[NR_TASKS] = {
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
// 	(WO_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
// };

// Final one is end of memory -> cant write further
// constexpr unsigned wo_memory_offset[NR_TASKS + 1] = {
// 	0,
// 	wo_memory_offset[0] + wo_memory_size[MS1_id],
// 	wo_memory_offset[1] + wo_memory_size[MS2_id],
// 	wo_memory_offset[2] + wo_memory_size[MS5_id],
// 	wo_memory_offset[3] + wo_memory_size[MS10_id],
// 	wo_memory_offset[4] + wo_memory_size[MS20_id],
// 	wo_memory_offset[5] + wo_memory_size[MS50_id],
// 	wo_memory_offset[6] + wo_memory_size[MS100_id],
// 	wo_memory_offset[7] + wo_memory_size[MS200_id],
// 	wo_memory_offset[8] + wo_memory_size[MS1000_id],
// 	wo_memory_offset[9] + wo_memory_size[MSANGLE_id]
// };

// Total number of bytes of each task for intercom
constexpr unsigned intercom_memory_size[NR_TASKS] = {
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS1_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS2_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS5_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS10_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS20_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS50_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS100_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS200_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MS1000_id],
	(INTERCOM_MEMORY / 100) * RUNABLES_SHARE[MSANGLE_id]
};

// Final one is end of memory -> cant write further, position in array
constexpr unsigned intercom_memory_offset[NR_TASKS + 1] = {
	0,
	intercom_memory_offset[0] + intercom_memory_size[MS1_id],
	intercom_memory_offset[1] + intercom_memory_size[MS2_id],
	intercom_memory_offset[2] + intercom_memory_size[MS5_id],
	intercom_memory_offset[3] + intercom_memory_size[MS10_id],
	intercom_memory_offset[4] + intercom_memory_size[MS20_id],
	intercom_memory_offset[5] + intercom_memory_size[MS50_id],
	intercom_memory_offset[6] + intercom_memory_size[MS100_id],
	intercom_memory_offset[7] + intercom_memory_size[MS200_id],
	intercom_memory_offset[8] + intercom_memory_size[MS1000_id],
	intercom_memory_offset[9] + intercom_memory_size[MSANGLE_id]
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


// [ANGLESYNC]
// Angle Sync Values, assume the worst case, so the shortest period.
constexpr unsigned CYLINDERS = 4;
constexpr unsigned MIN_RPM = 1000;
constexpr unsigned MAX_RPM = 3000;
// Formular is 120/(CYLINDERS*RPM)

// in ms -> every 40ms angle sync calculation is needed
constexpr unsigned LONGEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MIN_RPM);

// in ms -> every 3ms angle sync calculation is needed
constexpr unsigned SHORTEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MAX_RPM);

constexpr unsigned ANGLE_SYNC_PERIOD = (SHORTEST_ANGLE_SYNC_PERIOD + LONGEST_ANGLE_SYNC_PERIOD) / 2;
