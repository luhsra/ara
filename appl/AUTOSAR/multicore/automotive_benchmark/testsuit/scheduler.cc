// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"
#include "parameters.h"

DeclareTask(INIT);
DeclareTask(SCHED);
DeclareCounter(C1);
DeclareAlarm(A1);

DeclareTask(MS1);
DeclareTask(MS2);
DeclareTask(MS5);
DeclareTask(MS10);
DeclareTask(MS20);
DeclareTask(MS50);
DeclareTask(MS100);
DeclareTask(MS200);
DeclareTask(MS1000);

TEST_MAKE_OS_MAIN(StartOS(0))


/**
 * Test scheduling, where counter activates scheduler which sets tasks as active.
 * Uses Rate Monotonic Scheduling
 */

/**
 ******************** SCHEDULER ********************
 */
// small init task
TASK(INIT) {
    arch::Perf::start();

    kout << "\nRun new Scheduler Testcase" << endl;
	kout_task_data();

	#ifndef QEMU
		// to better see results on PI wait at the end before rebooting
		micro_sec_wait(2000000);
	#endif

    ara_timing_info(0, 1);
	kout << "\n*******************" << endl;
	kout << "Start" << endl;
    TerminateTask();	
}

// show debug prints, timings are not accurate then!
const bool debug_print = false;

// current cycle of scheduling
static unsigned cycle = 0;

// measure how often each tast runed
static StatusType res;
static unsigned start_counter[TASK_COUNT] = {0};
static unsigned blocked_counter[TASK_COUNT] = {0};
static unsigned finish_counter[TASK_COUNT] = {0};

// measure time between two schedule cycles
static unsigned int prev = 0;
static unsigned int cycle_diff[CYCLES] = {0};

// measure start and end time of each task
static unsigned int task_time[TASK_COUNT][CYCLES] = {0};
static unsigned int cycle_count[TASK_COUNT] = {0};

static unsigned int hookcounter = 0;
// 1x pre, 1x post, 1x post if idle
static unsigned int hooks[TASK_COUNT*CYCLES*3*10000] = {0};

static uint32_t* endtimes[TASK_COUNT] = {nullptr};

// main scheduler
TASK(SCHED) {
    ara_timing_info(10, 20);

    if (cycle >= CYCLES) {
		ara_timing_info(1, 2);

		kout << "End" << endl;
		kout << "*******************\n" << endl;
		
		/*
		// print time between each scheduel cylce
		for (unsigned i = 0; i < CYCLES; i++){
			kout << i << " c: " << cycle_diff[i] / WAIT_FREQUENCE << "us" << endl;
			if (i == WARMUP) {
				kout << "Start of run" << endl;
			} else if (i == COOLDOWN) {
				kout << "End of run" << endl;
			}
		}
		*/
		/*
		// print time that passed between starting and ending a task
		for (unsigned t = 0; t < TASK_COUNT; t++) {
			for (unsigned i = 0; i < CYCLES; i++){
				if (task_time[t][i] != 0){
					kout << "Task_id: " << t << " run_nr: " << i << " r: " << task_time[t][i] / WAIT_FREQUENCE << "us" << endl;
				}
			}
		}
		*/
		/*
		// print hook counter
		for (unsigned t = 0; t < TASK_COUNT*CYCLES*3*100; t+=2) {
			if (hooks[t] == 11){
				kout << "Post hook: " << (dec) << hooks[t+1] << endl;
			} else if (hooks[t] == 22){
				kout << "Pre hook: " << (dec) << hooks[t+1] << endl;
			}
		}
		*/

		// Print result
        kout << "\nResults for " << COOLDOWN - WARMUP << " scheduling cycles, each cycle " << SCHEDUL_INTERVAL << "us long:" << endl;
        for (unsigned i = 0; i < TASK_COUNT; i++) {
            kout << (dec) << taskStrings[i] << "\tblocked #/%: " << blocked_counter[i] << "/" << (100 * blocked_counter[i]) / start_counter[i];
			kout << "\tof #started_runs: " << start_counter[i] << "\tof #finished_runs: " << finish_counter[i] << endl;
        }
        kout << "\n" << endl;

        #ifndef QEMU
            // to better see results on PI wait at the end before rebooting
            micro_sec_wait(5000000);
        #endif

        ShutdownMachine();
    }

	cycle_diff[cycle] =  arch::Perf::get_cycles() - prev;
	prev = arch::Perf::get_cycles();
	
	if (debug_print) {
        kout << "\nSchedule round:" << cycle << endl;
	}
	
	if (WARMUP <= cycle && cycle < COOLDOWN){

		if (TASK_COUNT >= 1) {
			if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS1);
				start_counter[MS1_id]++;
				if (debug_print) {
					kout << "S " << MS1_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS1_id] << " still runnning!" << endl;
					}
					blocked_counter[MS1_id]++;
				}
			}
		}
		if (TASK_COUNT >= 2) {
			if (cycle % RUNABLES_PERIOD[MS2_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS2);
				start_counter[MS2_id]++;
				if (debug_print) {
					kout << "S " << MS2_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS2_id] << " still runnning!" << endl;
					}
					blocked_counter[MS2_id]++;
				}
			}
		}
		if (TASK_COUNT >= 3) {
			if (cycle % RUNABLES_PERIOD[MS5_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS5);
				start_counter[MS5_id]++;
				if (debug_print) {
					kout << "S " << MS5_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS5_id] << " still runnning!" << endl;
					}
					blocked_counter[MS5_id]++;
				}
			}
		}
		if (TASK_COUNT >= 4) {
			if (cycle % RUNABLES_PERIOD[MS10_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS10);
				start_counter[MS10_id]++;
				if (debug_print) {
					kout << "S " << MS10_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS10_id] << " still runnning!" << endl;
					}
					blocked_counter[MS10_id]++;
				}
			}
		
		}
		if (TASK_COUNT >= 5) {
			if (cycle % RUNABLES_PERIOD[MS20_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS20);
				start_counter[MS20_id]++;
				if (debug_print) {
					kout << "S " << MS20_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS20_id] << " still runnning!" << endl;
					}
					blocked_counter[MS20_id]++;
				}
			}
		}
		if (TASK_COUNT >= 6) {
			if (cycle % RUNABLES_PERIOD[MS50_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS50);
				start_counter[MS50_id]++;
				if (debug_print) {
					kout << "S " << MS50_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS50_id] << " still runnning!" << endl;
					}
					blocked_counter[MS50_id]++;
				}
			}
		}
		if (TASK_COUNT >= 7) {
			if (cycle % RUNABLES_PERIOD[MS100_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS100);
				start_counter[MS100_id]++;
				if (debug_print) {
					kout << "S " << MS100_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS100_id] << " still runnning!" << endl;
					}
					blocked_counter[MS100_id]++;
				}
			}
		}	
		if (TASK_COUNT >= 8) {
			if (cycle % RUNABLES_PERIOD[MS200_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS200);
				start_counter[MS200_id]++;
				if (debug_print) {
					kout << "S " << MS200_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS200_id] << " still runnning!" << endl;
					}
					blocked_counter[MS200_id]++;
				}
			}
		}
		if (TASK_COUNT >= 9) {
			if (cycle % RUNABLES_PERIOD[MS1000_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS1000);
				start_counter[MS1000_id]++;
				if (debug_print) {
					kout << "S " << MS1000_id << endl;
				}
				if (res == StatusType::E_OS_LIMIT) {
					if (debug_print) {
						kout << taskStrings[MS1000_id] << " still runnning!" << endl;
					}
					blocked_counter[MS1000_id]++;
				}
			}
		}
	}
	ara_timing_info(10, 11);
    cycle++;

	TerminateTask();
}


// typedef enum {
//     AUTOSAR_TASK_INVALID_TASK = 0,
//     AUTOSAR_TASK_INIT = 1,
//     AUTOSAR_TASK_SCHED = 2,
//     AUTOSAR_TASK_MS1 = 3,
//     AUTOSAR_TASK_MS2 = 4,
//     AUTOSAR_TASK_MS5 = 5,
//     AUTOSAR_TASK_MS10 = 6,
//     AUTOSAR_TASK_MS20 = 7,
//     AUTOSAR_TASK_MS50 = 8,
//     AUTOSAR_TASK_MS100 = 9,
//     AUTOSAR_TASK_MS200 = 10,
//     AUTOSAR_TASK_MS1000 = 11
// } TaskType;


// if (abc == nullptr) {
// 	kout << "null" << endl;
// }

void PostTaskHook() {
	TaskRefType a;
	uint32_t id;
	a = &id;
	GetTaskID(a);
	hooks[hookcounter++] = 11;
	hooks[hookcounter++] = id;
	if(id == 3) {
		kout << "MS1-Post"<< endl;
		if(endtimes[0] != nullptr) {
			kout << "not nul" << endl;
		}
		
	}
	// kout << arch::Perf::get_cycles() << endl;
}



void PreTaskHook() {
	TaskRefType a;
	uint32_t id;
	a = &id;
	GetTaskID(a);
	hooks[hookcounter++] = 22;
	hooks[hookcounter++] = id;
	// kout << arch::Perf::get_cycles() << endl;
	if(id == 3) {
		kout << "Pre-MS1"<< endl;
		if(endtimes[0] != nullptr) {
			kout << "not nul" << endl;
		}
	}
}


TASK(MS1) {
	const task_id id = MS1_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	// for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
	micro_sec_wait_end_time(t, endtimes[id]);
	// }
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	kout << "d" << endl;
	// endtimes[id] = nullptr;
	TerminateTask();
}
TASK(MS2) {
	const task_id id = MS2_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS5) {
	const task_id id = MS5_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS10) {
	const task_id id = MS10_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS20) {
	const task_id id = MS20_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS50) {
	const task_id id = MS50_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS100) {
	const task_id id = MS100_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS200) {
	const task_id id = MS200_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
TASK(MS1000) {
	const task_id id = MS1000_id;

	unsigned int c = arch::Perf::get_cycles();
	if (debug_print) {
		kout << id << " " << cycle_count[id] << "g" << endl;
	}
	
    unsigned const t = TOTAL_RUNTIME[id];
	ara_timing_info(t,t + 1);
	for (unsigned i = 0; i < SPLIT_PER_TASK[id]; i++) {
		micro_sec_wait(t / SPLIT_PER_TASK[id]);
	}
	
	if (debug_print) {
		kout << id << "e" << endl;
	}
	task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
	finish_counter[id]++;
	cycle_count[id]++;
	
	TerminateTask();
}
