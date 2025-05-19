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
#if defined(VARIANT_MIN)
	constexpr unsigned TASK_COUNT = 1;
#elif defined(VARIANT_SMALL)
	constexpr unsigned TASK_COUNT = 3;
#elif defined(VARIANT_BIG)
	constexpr unsigned TASK_COUNT = 6;
#elif defined(VARIANT_FULL)
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

// [Memory]
// Size of a single label in Byte, calculated by (1*35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2)/ 100 -> 2.66 Byte
// 90% of Labels are 1,2,4 Bytes, calculated average was 3 Bytes
constexpr unsigned AVAERAGE_LABEL_SIZE = 3;
constexpr unsigned LABELS_PER_RUNABLE = NUMBER_OF_LABELS / NUMBER_OF_RUNABLES;

// Of that: 40% read, 10% write, 50% read/write
constexpr unsigned RO_SHARE = 40;
// constexpr unsigned WO_SHARE = 10; // ignored for now
constexpr unsigned RW_SHARE = 50;
constexpr unsigned RO_MEMORY = (NUMBER_OF_LABELS / 100) * RO_SHARE * AVAERAGE_LABEL_SIZE;
// constexpr unsigned WO_MEMORY = (NUMBER_OF_LABELS / 100) * WO_SHARE * AVAERAGE_LABEL_SIZE; // ignored for now
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

// in ms -> every 30ms angle sync calculation is needed
constexpr unsigned LONGEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MIN_RPM);
// in ms -> every 10ms angle sync calculation is needed
constexpr unsigned SHORTEST_ANGLE_SYNC_PERIOD = 1000 * 120 / (CYLINDERS * MAX_RPM);
// Average angle sync period, used for trig-angle testcase
constexpr unsigned ANGLE_SYNC_PERIOD = (SHORTEST_ANGLE_SYNC_PERIOD + LONGEST_ANGLE_SYNC_PERIOD) / 2;
