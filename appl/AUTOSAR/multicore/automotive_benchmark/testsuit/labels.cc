#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"
#include "parameters.h"

DeclareTask(SCHED1);
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
 * Test large number of runnables that get started in predifined periods
 * and allocate lables -> memory to them
 * FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */


/**
 ******************** SCHEDULER ********************
 startup + control Task, lowest scheduling priority
 */

unsigned cycle = 0;
TASK(SCHED1) {
	arch::Perf::start();

	kout << "\nRunnables Testcase" << endl;
	kout_run_info();
	micro_sec_wait(1000000);

	uint32_t start_cycle, end_cycle;
	bool in_time;

	for (; cycle < CYCLES; cycle++) {

		start_cycle = arch::Perf::get_cycles();

		if (cycle % RUNABLES_PERIOD[MS1_id] == 0) {
			memory_pos = memory_positions[MS1_id];
			ActivateTask(MS1);
		}	
		if (cycle % RUNABLES_PERIOD[MS2_id] == 0) {
			memory_pos = memory_positions[MS2_id];
			ActivateTask(MS2);
		}
		if (cycle % RUNABLES_PERIOD[MS5_id] == 0) {
			memory_pos = memory_positions[MS5_id];
			ActivateTask(MS5);
		}
		if (cycle % RUNABLES_PERIOD[MS10_id] == 0) {
			memory_pos = memory_positions[MS10_id];
			ActivateTask(MS10);
		}
		if (cycle % RUNABLES_PERIOD[MS20_id] == 0) {
			memory_pos = memory_positions[MS20_id];
			ActivateTask(MS20);
		}
		if (cycle % RUNABLES_PERIOD[MS50_id] == 0) {
			memory_pos = memory_positions[MS50_id];
			ActivateTask(MS50);
		}
		if (cycle % RUNABLES_PERIOD[MS100_id] == 0) {
			memory_pos = memory_positions[MS100_id];
			ActivateTask(MS100);
		}
		if (cycle % RUNABLES_PERIOD[MS200_id] == 0) {
			memory_pos = memory_positions[MS200_id];
			ActivateTask(MS200);
		}
		if (cycle % RUNABLES_PERIOD[MS1000_id] == 0) {
			memory_pos = memory_positions[MS1000_id];
			ActivateTask(MS1000);
		}

		end_cycle = arch::Perf::get_cycles();

		in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');

		// Debug help
		/*
		if (!in_time) {
			// kout << "Cycle:\t" << cycle << "\tfailed its timing!" << endl;
		}
		*/
		/*
		kout << "Max_time: " << SCHEDUL_INTERVAL * WAIT_FREQUENCE << "\tused: " << end_cycle - start_cycle << endl;	
		kout << "start_cycle: " << start_cycle << "\tend_cycle: " << end_cycle << endl;	
		kout << "Cycle Nr:\t" << cycle << "\tIn time? " << in_time << "\n" << endl;
		*/
	}

	TerminateTask();
}

void workTask(task_id task) {

	uint32_t start_cycle = arch::Perf::get_cycles();

	const unsigned runnables = (NUMBER_OF_RUNNABLES/100) * RUNABLES_SHARE[task];
	// calculation time
	const unsigned time = runnables * TIME_PER_RUNNABLE[task];
	// label size
	const unsigned memory = runnables * MEMORY_PER_RUNNABLE;
	
	const unsigned reads = runnables * READ_ACCESSES_PER_RUNNABLE;
	const unsigned writes = runnables * WRITE_ACCESSES_PER_RUNNABLE;
	const unsigned read_writes = runnables * RW_ACCESSES_PER_RUNNABLE;

	// READS
	uint8_t tmp = 1;
	// compiler wegoptimiert das?
	for (unsigned i = 0; i < reads; memory_pos++, i++) {
		tmp += communication[memory_pos];
	}

	// WRITES
	for (unsigned i = 0; i < writes; memory_pos++, i++) {
		communication[memory_pos] = tmp;
	}

	// READ + WRITES

	// first write into memory of the tasks of the first activation period
	unsigned receiver_task = 0;
	unsigned labels_send_to_receiver = 0;
	unsigned receiver_memory_pos = memory_positions[receiver_task];

	for (unsigned i = 0; i < read_writes; memory_pos++, i++) {

		// Debugging help
		// kout << "task: " << task << "rw: " << read_writes <<  " i: " << i << " receiver_task " << receiver_task << endl;
		// kout << "memory_pos: " << memory_pos << "labels_send_to_receiver: " << labels_send_to_receiver <<  " receiver_memory_pos: " << receiver_memory_pos << endl;

		// Interprocess communication, receiver_task == 9 means all remaining communication goes to intraprocess
		if (receiver_task < NR_TASKS) {
			// read from senders runnable memory, write to receiver runnable memory
			tmp = communication[memory_pos] + 1;
			communication[receiver_memory_pos] = tmp;

			receiver_memory_pos++;
			labels_send_to_receiver++;

			if (labels_send_to_receiver >= INTER_TASK_RATIO[task][receiver_task]) {
				receiver_task++;
				labels_send_to_receiver = 0;
				receiver_memory_pos = memory_positions[receiver_task];
			}
			// Debugging help
			// kout << "Waiting!" <<  endl;
			// micro_sec_wait(500000);

		// Intraprocess communication
		} else {
			tmp = communication[memory_pos] + 1;
			communication[memory_pos] = tmp;
		}

	}
	
	bool in_time = micro_sec_wait_upto(start_cycle, time);
	if (!in_time) {
		kout << "Task: " << taskStrings[task] << "\t in Cycle: " << cycle << "\ttook longer because of memory." << endl;
	}
	
	return;
}


TASK(MS1) {
	workTask(task_id::MS1_id);
	TerminateTask();
}
TASK(MS2) {
	workTask(task_id::MS2_id);
	TerminateTask();
}
TASK(MS5) {
	workTask(task_id::MS5_id);
	TerminateTask();
}
TASK(MS10) {
	workTask(task_id::MS10_id);
	TerminateTask();
}
TASK(MS20) {
	workTask(task_id::MS20_id);
	TerminateTask();
}
TASK(MS50) {
	workTask(task_id::MS50_id);
	TerminateTask();
}
TASK(MS100) {
	workTask(task_id::MS100_id);
	TerminateTask();
}
TASK(MS200) {
	workTask(task_id::MS200_id);
	TerminateTask();
}
TASK(MS1000) {
	workTask(task_id::MS1000_id);
	TerminateTask();
}

void PreIdleHook() {
   
    kout << "\n*******************" << endl;

	kout_task_data();
	kout_intercom_data();

	kout << "\nFrom: " << CYCLES << " Cycles are:" << endl;
	kout << "\t# in Time: " << count_trace('1') << "\t\t| Failed: " << count_trace('0') << "\n" << endl;
#ifndef QEMU
	// to better see results on PI wait at the end before rebooting
	micro_sec_wait(5000000);
#endif

	test_finish();
	ShutdownMachine();

}
