// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * Config file for testsuit benchmarks, defines different values for paramaters that describe the size and the properties of the system.
 * Only one variant is active at the same time, set by meson.
 */

/**
 ******************** DEFINEs ********************
 * Control what gets measured and printed at the end, comment in or out.
 */
// [PRINTING]
// At end of run print time spend between each call of TASK(SCHED), should be equal to SCHEDUL_INTERVAL
// #define PRINT_CYCLE_TIMING
// At end of run print time that passed between start and end of each run of each task
// #define PRINT_TASK_TIMING
// At end of run print time spend in hooks
// #define PRINT_HOOK_STATS

// At end of run print stats about the runned tasks
// #define PRINT_TASK_DATA
// At end of run print memory setup
// #define PRINT_MEM_DATA

// At end of run print how often each task completed or got blocked because the previous run was still running
// #define PRINT_RUN_STATS
// At end of run print time spent idling
// #define PRINT_MEASURED_LOAD

// prints the result for the automated benchmark
#define BENCHMARK

// [CONFIG]
// Way fewer cycles, usefull to view timing/hook_stats
// #define SHORT_RUN
// Only do read only memory and exlude intercom memory
// #define READ_ONLY
// Active the angle sync task in the fixed intervall ANGLE_SYNC_PERIOD
#define TRIG_ANGLE

/**
 ******************** SYSTEM CONFIG ********************
 * from Paper: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */
// [Variants/Task count]
// 10 different activation periods, each representing a task each. From 1ms to 1000ms
constexpr unsigned NR_TASKS = 10;
// Only use the X first tasks, starting with the shortest scheduling intervals. Angle sync
// With all tasks analysis might take very long! (for 7 Tasks ~200s, for 8 Tasks ~1340s)
// #if defined(VARIANT_MIN)
// 	constexpr unsigned TASK_COUNT = 1;
// #elif defined(VARIANT_SMALL)
// 	constexpr unsigned TASK_COUNT = 3;
// #elif defined(VARIANT_BIG)
// 	constexpr unsigned TASK_COUNT = 6;
// #elif defined(VARIANT_FULL)
// 	constexpr unsigned TASK_COUNT = 9;
// #else
// 	constexpr unsigned TASK_COUNT = 3;
// #endif
#if defined(VARIANT_1)
	constexpr unsigned TASK_COUNT = 1;
#elif defined(VARIANT_2)
	constexpr unsigned TASK_COUNT = 2;
#elif defined(VARIANT_3)
	constexpr unsigned TASK_COUNT = 3;
#elif defined(VARIANT_4)
	constexpr unsigned TASK_COUNT = 4;
#elif defined(VARIANT_5)
	constexpr unsigned TASK_COUNT = 5;
#elif defined(VARIANT_6)
	constexpr unsigned TASK_COUNT = 6;
#elif defined(VARIANT_7)
	constexpr unsigned TASK_COUNT = 7;
#elif defined(VARIANT_8)
	constexpr unsigned TASK_COUNT = 8;
#elif defined(VARIANT_9)
	constexpr unsigned TASK_COUNT = 9;
#else
	constexpr unsigned TASK_COUNT = 3;
#endif
static_assert(TASK_COUNT <= NR_TASKS);

// [Simulation cycles]
// How many times the schedueler is activated, each cycle is SCHEDUL_INTERVAL long.
// The longest activation period is every 1000 cycles.
#if defined(SHORT_RUN)
	constexpr unsigned CYCLES = 30;
#else
	constexpr unsigned CYCLES = 1000;
#endif
constexpr unsigned WARMUP_CYCLES = 10;	// First cycles do not start tasks.
constexpr unsigned COOLDOWN_CYCLES = 10;	// Cycles with no new tasks, but running ones can finish
constexpr unsigned TOTAL_CYLES = CYCLES + WARMUP_CYCLES + COOLDOWN_CYCLES;
constexpr unsigned FIRST_CYCLE = WARMUP_CYCLES;
constexpr unsigned LAST_CYCLE = TOTAL_CYLES - COOLDOWN_CYCLES;
// In what intervall the software scheduler tries to start new tasks.
// Needs to match cycletime of alarm in system.json!
constexpr unsigned SCHEDUL_INTERVAL = 1000; //um -> 1000us = 1ms

// [Runnables count]
// Number of runnables that get distributed to tasks/activation periods, acording to the percentages
// in RUNABLES_SHARE. Increase to add a higher load.
// The paper list a range of 1000 - 1500
 constexpr unsigned NUMBER_OF_RUNABLES = 1000;

// [Label count]
// Number of labels/memory regions for communication on the system, each is AVAERAGE_LABEL_SIZE byte.
// Is ignored if memory is not measured.
constexpr unsigned NUMBER_OF_LABELS = 10000;
 

/**
 ******************** Static Variables ********************
 from Paper: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */
// [Tasks]
// Name of each task
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000", "MSANGLE"};
enum task_id { MS1_id = 0, MS2_id = 1, MS5_id = 2, MS10_id = 3, MS20_id = 4, MS50_id = 5, MS100_id = 6, MS200_id = 7, MS1000_id = 8, MSANGLE_id = 9, MS_LAST_id = 10};
// Percentage share of each activation period of the total NUMBER_OF_RUNABLES
constexpr unsigned RUNABLES_SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4, 15};
// Given activation periods in which runnables get triggered (in millisecond/ms).
// Angle_syncs period is calculated seperaty. TODO could modify slightly to decrease spike at multiple dividors
constexpr unsigned RUNABLES_PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000, 0};
// Average execution time of a single runnables in a specific activation period (in microseconds/us)
constexpr unsigned TIME_PER_RUNABLE[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1, 7};
// How many runnables each tasks consist
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
