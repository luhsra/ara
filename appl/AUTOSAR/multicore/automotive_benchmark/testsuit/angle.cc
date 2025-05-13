// SPDX-FileCopyrightText: 2025 Mareike Burg
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"
#include "parameters.h"
#include "helper.h"

DeclareTask(INIT);
DeclareTask(SCHED);
DeclareCounter(C1);
DeclareAlarm(A1);

// für Multicore
// DeclareTask(MS1-a);
// DeclareTask(MS1-a);
DeclareTask(MS1);
DeclareTask(MS1);
DeclareTask(MS2);
DeclareTask(MS5);
DeclareTask(MS10);
DeclareTask(MS20);
DeclareTask(MS50);
DeclareTask(MS100);
DeclareTask(MS200);
DeclareTask(MS1000);
DeclareTask(MSANGLE);

int main(void) {                                                                                                   
	StartOS(0);
}

/**
 * Testcase with new scheduler and seperate angle sync tasks
 */


// current cycle of scheduling
static unsigned cycle = 0;
// the time when a running task is done with its calculations, gets changed when tasks is preempt
static uint32_t calculate_until[TASK_COUNT] = {0};
// keep track what time it was when the task entered its PostTaskHook
static uint32_t time_when_stopped[TASK_COUNT] = {0};

static uint32_t angle_calculate_until = 0;
static uint32_t angle_time_when_stopped = 0;
/**
 ******************** OS TASKS ********************
 */
// Small Init Task
TASK(INIT) {
    setup_and_print("angle sync no mem");
    ara_timing_info(1, 5);
    TerminateTask();
}


// Main Scheduler, activated by AUTOSAR Counter
TASK(SCHED) {
    ara_timing_info(10, 25);

    if (cycle >= CYCLES) {
		print_results();
        ShutdownMachine();
    }

	#if defined(PRINT_CYCLE_TIMING) || defined(PRINT_HOOK_STATS) || defined(PRINT_IDLE)
		uint32_t t = arch::Perf::get_cycles();
	#endif

	#ifdef PRINT_CYCLE_TIMING
		cycle_diff[cycle] = t - prev;
		prev = t;
	#endif
	
	#ifdef PRINT_HOOK_STATS
		hooks[hookcounter][0] = hook_type::sched;
		hooks[hookcounter][1] = cycle;
		hooks[hookcounter][2] = t;
		hooks[hookcounter][3] = hook_idle;
		hooks[hookcounter][4] = t - hook_start_of_idle;
		hookcounter++;
	#endif

	#ifdef PRINT_IDLE
		if (WARMUP <= cycle && cycle <= COOLDOWN){
			if (idle == true){
				idle_total += t - start_of_idle;
			}
		}
	#endif

	StatusType res;
	if (WARMUP <= cycle && cycle < COOLDOWN){

		if (TASK_COUNT >= 1) {
			if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS1);
				#ifdef PRINT_RUN_STATS
					start_counter[MS1_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS1_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 2) {
			if (cycle % RUNABLES_PERIOD[MS2_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS2);
				#ifdef PRINT_RUN_STATS
					start_counter[MS2_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS2_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 3) {
			if (cycle % RUNABLES_PERIOD[MS5_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS5);
				#ifdef PRINT_RUN_STATS
					start_counter[MS5_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS5_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 4) {
			if (cycle % RUNABLES_PERIOD[MS10_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS10);
				#ifdef PRINT_RUN_STATS
					start_counter[MS10_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS10_id]++;
					#endif
				}
			}
		
		}
		if (TASK_COUNT >= 5) {
			if (cycle % RUNABLES_PERIOD[MS20_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS20);
				#ifdef PRINT_RUN_STATS
					start_counter[MS20_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS20_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 6) {
			if (cycle % RUNABLES_PERIOD[MS50_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS50);
				#ifdef PRINT_RUN_STATS
					start_counter[MS50_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS50_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 7) {
			if (cycle % RUNABLES_PERIOD[MS100_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS100);
				#ifdef PRINT_RUN_STATS
					start_counter[MS100_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS100_id]++;
					#endif
				}
			}
		}	
		if (TASK_COUNT >= 8) {
			if (cycle % RUNABLES_PERIOD[MS200_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS200);
				#ifdef PRINT_RUN_STATS
					start_counter[MS200_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS200_id]++;
					#endif
				}
			}
		}
		if (TASK_COUNT >= 9) {
			if (cycle % RUNABLES_PERIOD[MS1000_id] == 0) {
				ara_timing_info(4, 5);
				res = ActivateTask(MS1000);
				#ifdef PRINT_RUN_STATS
					start_counter[MS1000_id]++;
				#endif
				if (res == StatusType::E_OS_LIMIT) {
					#ifdef PRINT_RUN_STATS
						blocked_counter[MS1000_id]++;
					#endif
				}
			}
		}
	}
    cycle++;

	TerminateTask();
}

// ISR to start Angle Sync Task, would be triggered externally
// ISR2 because of 2nd Category, Name is ISR1
ISR2(ISR1) {
	ActivateTask(MSANGLE);
}


/**
 ******************** HOOKS ********************
 */
// called on context switch, still in old task 
void PostTaskHook() {
	TaskRefType trt;
	uint32_t id;
	trt = &id;
	GetTaskID(trt);
	task_id t_id = translate_task_type(id);

	// ignore hooks from scheduler
	if (t_id != task_id::MS_LAST_id) {

		uint32_t t = arch::Perf::get_cycles();
		#ifdef PRINT_HOOK_STATS
			hooks[hookcounter][0] = hook_type::post;
			hooks[hookcounter][1] = t_id;
			hooks[hookcounter][2] = t;
			if (t_id == task_id::MSANGLE_id) {
				hooks[hookcounter][3] = angle_calculate_until;
			}
			else {
				hooks[hookcounter][3] = calculate_until[t_id];
			}
			
			hookcounter++;

			hook_idle = true;
			hook_start_of_idle = t;
		#endif

		#ifdef PRINT_IDLE
			idle = true;
			start_of_idle = t;
		#endif

		if (t_id == task_id::MSANGLE_id) {
			// when calculate_until is set, this task was still in calculation.
			if (angle_calculate_until != 0) {
				angle_time_when_stopped = t;
	
				#ifdef PRINT_HOOK_STATS
					hook_idle = false;
				#endif
	
				#ifdef PRINT_IDLE
					idle = false;
				#endif
	
			}
		} else {
			// when calculate_until is set, this task was still in calculation.
			if (calculate_until[t_id] != 0) {
				time_when_stopped[t_id] = t;
	
				#ifdef PRINT_HOOK_STATS
					hook_idle = false;
				#endif
	
				#ifdef PRINT_IDLE
					idle = false;
				#endif
	
			}
		}
		

	}
}

// called on context switch, before entering new task
void PreTaskHook() {
	TaskRefType trt;
	uint32_t id;
	trt = &id;
	GetTaskID(trt);
	task_id t_id = translate_task_type(id);

	// ignore hooks from scheduler
	if (t_id != task_id::MS_LAST_id) {

		uint32_t t = arch::Perf::get_cycles();
		#ifdef PRINT_HOOK_STATS
			hooks[hookcounter][0] = hook_type::pre;
			hooks[hookcounter][1] = t_id;
			hooks[hookcounter][2] = t;
			hooks[hookcounter][3] = calculate_until[t_id];
		#endif
		
		if (t_id == task_id::MSANGLE_id) {
			if (angle_time_when_stopped != 0) {
				angle_calculate_until += t - angle_time_when_stopped;
				angle_time_when_stopped = 0;
			}
		} else {
			// when time_when_stopped is set, this task was preempted in calculation.
			if (time_when_stopped[t_id] != 0) {
				calculate_until[t_id] += t - time_when_stopped[t_id];
				time_when_stopped[t_id] = 0;
			}
		}

		#ifdef PRINT_HOOK_STATS
			hooks[hookcounter][4] = calculate_until[t_id];
			hookcounter++;
		#endif
	}
}


/**
 ******************** WORKER TASKS ********************
 */
TASK(MS1) {
	const task_id id = MS1_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS2) {
	const task_id id = MS2_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS5) {
	const task_id id = MS5_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS10) {
	const task_id id = MS10_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS20) {
	const task_id id = MS20_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS50) {
	const task_id id = MS50_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS100) {
	const task_id id = MS100_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS200) {
	const task_id id = MS200_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MS1000) {
	const task_id id = MS1000_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &calculate_until[id];
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		task_time[id][cycle_count[id]] = arch::Perf::get_cycles() - c;
		cycle_count[id]++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		finish_counter[id]++;
	#endif

	TerminateTask();
}
TASK(MSANGLE) {
	const task_id id = MSANGLE_id;
	ara_timing_info(TOTAL_RUNTIME[id], TOTAL_RUNTIME[id] + 1);

	#ifdef PRINT_TASK_TIMING
		unsigned int c = arch::Perf::get_cycles();
	#endif
	
	// create pointer, so end_times can be modified in hooks
	uint32_t* end_time = &angle_calculate_until;
	micro_sec_wait_end_time(TOTAL_RUNTIME[id], end_time);
	
	#ifdef PRINT_TASK_TIMING
		angle_task_time[angle_cycle_count] = arch::Perf::get_cycles() - c;
		angle_cycle_count++;
	#endif
	
	#ifdef PRINT_RUN_STATS
		angle_finish_counter++;
	#endif

	TerminateTask();
}
