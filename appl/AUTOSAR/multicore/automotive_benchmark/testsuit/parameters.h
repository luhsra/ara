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

 NUMBER_OF_RUNNABLES
 Number of runnables that gets distributed acording to the percentages in RUNABLES_SHARE
 -> main option to modify systems load

 NUMBER_OF_LABELS
 Number of all labels on the system, each is AVAERAGE_LABEL_SIZE big
 -> modify impact of memory operation (ignored if memory memory is not measured)
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
// Cycles ignored at the start.
constexpr unsigned WARMUP = 10;
// Cycles at the end, where no new tasks are started but running ones can finish.
constexpr unsigned COOLDOWN = CYCLES - 10;

/**
 ******************** DEFINEs ********************
 * Control what gets measured and printed at the end, comment in or out.
 */

// At start of run print variant and its values
#define PRINT_VARIANT

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
constexpr unsigned TASK_COUNT = 3;
static_assert(TASK_COUNT <= NR_TASKS);


// Name of each task
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000", "MSANGLE"};
enum task_id { MS1_id = 0, MS2_id = 1, MS5_id = 2, MS10_id = 3, MS20_id = 4, MS50_id = 5, MS100_id = 6, MS200_id = 7, MS1000_id = 8, MSANGLE_id = 9, MS_LAST_id = 10};

// Percentage share of each activation period of the total NUMBER_OF_RUNNABLES
constexpr unsigned RUNABLES_SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4, 15};
// Given activation periods in which runnables get triggered (in millisecond/ms)
constexpr unsigned RUNABLES_PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000, ANGLE_SYNC_PERIOD};   // TODO could modify slightly to decrease spike at multiples
// Average execution time of a single runnables in a specific activation period (in microseconds/us)
constexpr unsigned TIME_PER_RUNNABLE[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1, 7};
// Total runtime of each task
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
// Overwrite for testing
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

// [MEMORY]
// AVAERAGE_LABEL_SIZE: Size of a single label in Byte, calculated by (1*35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2)/ 100 -> 2.66 Byte
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



// [ANGLESYNC]
// Angle Sync Values, assume the worst case, so the shortest period. So a bit car with 8 Cylinders and 5000 rpm
constexpr unsigned CYLINDERS = 8;
constexpr unsigned RPM = 5000;
// Formular is 60/(CYLINDERS*RPM) -> then convert into s (*60) -> then into milliseconds * 1000
constexpr unsigned ANGLE_SYNC_PERIOD = (1000*60*60)/(CYLINDERS * RPM);

