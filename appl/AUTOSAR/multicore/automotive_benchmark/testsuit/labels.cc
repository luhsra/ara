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

const unsigned NR_TASKS = 9;
const char* taskStrings[NR_TASKS] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000"};
enum task_id {
	MS1_id = 0,
	MS2_id = 1,
	MS5_id = 2,
	MS10_id = 3,
	MS20_id = 4,
	MS50_id = 5,
	MS100_id = 6,
	MS200_id = 7,
	MS1000_id = 8,
	MS_LAST_id = 9,
};

// TODO add parameters.h

// how often the scheduler gets started
const unsigned CYCLES = 1000;
// start new runnables each ms = 1000um
const unsigned SCHEDUL_INTERVAL = 1000;

// #runnables-> how many runnables are 1% of system
const unsigned NUMBER_OF_RUNNABLES = 1000;
// -> how many runnables are 1% of system
const unsigned RUNNABLES_PER100 = NUMBER_OF_RUNNABLES / 100;
// Predifined periods to trigger runnables (in ms)
const unsigned PERIOD[NR_TASKS] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};
// const unsigned PERIOD[] = {1, 2, 7, 11, 23, 51, 104, 199, 1003};
// Share of these periods (in %)
const unsigned SHARE[NR_TASKS] = {3, 2, 2, 25, 25, 3, 20, 1, 4}; // !!! only up to 85% since angle-sync is missing
// Average execution time in microseconds (in us)
const unsigned TIME[NR_TASKS] = {5, 5, 12, 11, 9, 18, 11, 3, 1};


// labels
const unsigned NUMBER_OF_LABELS = 10000;
const unsigned LABELS_PER1000 = NUMBER_OF_LABELS/1000;
/* alternative version to not use avarage label size
// 1, 2, 4, (5-)8, (9-)16, (17-)32, (33-)64, >64 -> 128 	Bytes
const unsigned LABEL_SIZE[] = 	{1, 	2, 	 4, 8,  16, 32, 64, 128};
const unsigned LABEL_SHARE[] = 	{350, 490, 130, 8, 13,  5,  2, 2};
const unsigned LABEL_AREA = LABELS_PER1000*LABEL_SHARE[0]*LABEL_SIZE[0] + LABELS_PER1000*LABEL_SHARE[1]*LABEL_SIZE[1]
						 +  LABELS_PER1000*LABEL_SHARE[2]*LABEL_SIZE[2] + LABELS_PER1000*LABEL_SHARE[3]*LABEL_SIZE[3] 
						 +  LABELS_PER1000*LABEL_SHARE[4]*LABEL_SIZE[4] + LABELS_PER1000*LABEL_SHARE[5]*LABEL_SIZE[5]
						 +  LABELS_PER1000*LABEL_SHARE[6]*LABEL_SIZE[6] + LABELS_PER1000*LABEL_SHARE[7]*LABEL_SIZE[7];
*/
// should be(35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2 )/ 100 -> 2.66 Byte
const unsigned AVAERAGE_LABEL_SIZE = 30;
// Of that: 40% read, 10% write, 50% read/write
const unsigned READ_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 40 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned WRITE_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE* 10 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned RW_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 50 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned SIZE_PER_RUNNABLE = READ_ACCESSES_PER_RUNNABLE + WRITE_ACCESSES_PER_RUNNABLE + RW_ACCESSES_PER_RUNNABLE;

uint8_t communication[NUMBER_OF_LABELS * AVAERAGE_LABEL_SIZE];
uint16_t memory_pos = 0;

/*
enum memory_position {
	MS1_mem = 0,
	MS2_mem = RUNNABLES_PER100 * SHARE[MS1_id] * SIZE_PER_RUNNABLE,
	MS5_mem = MS2_mem + RUNNABLES_PER100 * SHARE[MS2_id] * SIZE_PER_RUNNABLE,
	MS10_mem = MS5_mem + RUNNABLES_PER100 * SHARE[MS5_id] * SIZE_PER_RUNNABLE,
	MS20_mem = MS10_mem + RUNNABLES_PER100 * SHARE[MS10_id] * SIZE_PER_RUNNABLE,
	MS50_mem = MS20_mem + RUNNABLES_PER100 * SHARE[MS20_id] * SIZE_PER_RUNNABLE,
	MS100_mem = MS50_mem + RUNNABLES_PER100 * SHARE[MS50_id] * SIZE_PER_RUNNABLE,
	MS200_mem = MS100_mem + RUNNABLES_PER100 * SHARE[MS100_id] * SIZE_PER_RUNNABLE,
	MS1000_mem = MS200_mem + RUNNABLES_PER100 * SHARE[MS200_id] * SIZE_PER_RUNNABLE,
	MS_END_mem = MS1000_mem + RUNNABLES_PER100 * SHARE[MS1000_id] * SIZE_PER_RUNNABLE,
};*/

// Final one is end of memory -> cant write further
const unsigned memory_positions[NR_TASKS + 1] = {
	0,
	RUNNABLES_PER100 * SHARE[MS1_id] * SIZE_PER_RUNNABLE,
	memory_positions[1] + RUNNABLES_PER100 * SHARE[MS2_id] * SIZE_PER_RUNNABLE,
	memory_positions[2] + RUNNABLES_PER100 * SHARE[MS5_id] * SIZE_PER_RUNNABLE,
	memory_positions[3] + RUNNABLES_PER100 * SHARE[MS10_id] * SIZE_PER_RUNNABLE,
	memory_positions[4] + RUNNABLES_PER100 * SHARE[MS20_id] * SIZE_PER_RUNNABLE,
	memory_positions[5] + RUNNABLES_PER100 * SHARE[MS50_id] * SIZE_PER_RUNNABLE,
	memory_positions[6] + RUNNABLES_PER100 * SHARE[MS100_id] * SIZE_PER_RUNNABLE,
	memory_positions[7] + RUNNABLES_PER100 * SHARE[MS200_id] * SIZE_PER_RUNNABLE,
	memory_positions[8] + RUNNABLES_PER100 * SHARE[MS1000_id] * SIZE_PER_RUNNABLE
};

// InterTask Communication Patter
// with MS1 MS2 MS5 MS10 MS20 MS50 MS100 MS200 MS1000
// 0 = 0, I = 5, II = 25, III = 75, IV = 250, V = 750, VI = 1250
const unsigned INTER_TASK_RATIO[NR_TASKS][NR_TASKS] = {{25, 0, 0, 5, 5, 0, 5, 0, 0},
										{0, 25, 0, 5, 5, 0, 5, 0, 0},
										{0, 5, 250, 250, 25, 25, 5, 0, 0},
										{25, 25, 25, 1250, 250, 25, 250, 25, 75},
										{5, 5, 5, 250, 1250, 25, 250, 5, 25},
										{0, 0, 25, 25, 25, 75, 5, 0, 0},
										{0, 5, 5, 750, 250, 25, 1250, 25, 75},
										{0, 0, 0, 5, 5, 0, 5, 5, 5},
										{0, 0, 0, 75, 25, 0, 75, 5, 250} };

/**
 ******************** SCHEDULER ********************
 */

// startup + control Task, loweest prio
unsigned cycle = 0;
TASK(SCHED1) {
	arch::Perf::start();
    kout << "********************" << endl;
	kout << "Label Test w\t" << NUMBER_OF_RUNNABLES << "\tRunnables and\t" << NUMBER_OF_LABELS << "\tLabels." << endl;
	kout << "\t\t" << AVAERAGE_LABEL_SIZE << "\tAvarage Labelsize" << endl;
    kout << "********************" << endl;

	// optionaly wait
	// micro_sec_wait(30000000);

	for (; cycle < CYCLES; cycle++) {

		uint32_t start_cycle = arch::Perf::get_cycles();

		if (cycle % PERIOD[MS1_id] == 0) {
			memory_pos = memory_positions[MS1_id];
			ActivateTask(MS1);
		}	
		if (cycle % PERIOD[MS2_id] == 0) {
			memory_pos = memory_positions[MS2_id];
			ActivateTask(MS2);
		}
		if (cycle % PERIOD[MS5_id] == 0) {
			memory_pos = memory_positions[MS5_id];
			ActivateTask(MS5);
		}
		if (cycle % PERIOD[MS10_id] == 0) {
			memory_pos = memory_positions[MS10_id];
			ActivateTask(MS10);
		}
		if (cycle % PERIOD[MS20_id] == 0) {
			memory_pos = memory_positions[MS20_id];
			ActivateTask(MS20);
		}
		if (cycle % PERIOD[MS50_id] == 0) {
			memory_pos = memory_positions[MS50_id];
			ActivateTask(MS50);
		}
		if (cycle % PERIOD[MS100_id] == 0) {
			memory_pos = memory_positions[MS100_id];
			ActivateTask(MS100);
		}
		if (cycle % PERIOD[MS200_id] == 0) {
			memory_pos = memory_positions[MS200_id];
			ActivateTask(MS200);
		}
		if (cycle % PERIOD[MS1000_id] == 0) {
			memory_pos = memory_positions[MS1000_id];
			ActivateTask(MS1000);
		}

		uint32_t end_cycle = arch::Perf::get_cycles();

		bool in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');

		if (!in_time) {
			// kout << "Cycle:\t" << cycle << "\tfailed overall timing" << endl;
		}

		/*
		kout << "t: " << 1000 * WAIT_FREQUENCE << " d: " << end_cycle - start_cycle << endl;	
		kout << "s: " << start_cycle << " e: " << end_cycle << endl;	
		kout << "Run: \t" << cycle << " | In time? " << in_time << "\n" << endl;
		*/
	}

	TerminateTask();
}

void workTask(task_id task) {

	uint32_t start_cycle = arch::Perf::get_cycles();

	const unsigned runs = RUNNABLES_PER100 * SHARE[task];
	// calculation time
	const unsigned time = runs * TIME[task];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	const unsigned reads = runs * READ_ACCESSES_PER_RUNNABLE;
	const unsigned writes = runs * WRITE_ACCESSES_PER_RUNNABLE;
	const unsigned read_writes = runs * RW_ACCESSES_PER_RUNNABLE;

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
		kout << "Cycle:\t" << cycle << "\t" << taskStrings[task] << "\ttook longer because of memory" << endl;
	}
	// Debugging
	// kout << "Finished after Task: " << task << endl;
	// micro_sec_wait(500000);
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
    kout << "END - Test w\t" << NUMBER_OF_RUNNABLES << "\tRunnables and\t" << NUMBER_OF_LABELS << "\tLabels." << endl;
	kout << "\t\t" << AVAERAGE_LABEL_SIZE << "\tAvarage Labelsize" << endl;
    kout << "*******************" << endl;


	// Debug Print Runnables Distribution and Runtime 
    kout << "\n*******************" << endl;
	kout << "\n\nTASKPERIOD| NUMBER OF RUNNABLES | EXPECTED RUNTIME" << endl;
    kout << "*******************\n\t";
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout << taskStrings[i] << "\t\t| " << RUNNABLES_PER100 * SHARE[i] << "x \t\t| " << RUNNABLES_PER100 * SHARE[i] * TIME[i] << "us" << endl;
	}
	
	// Debug Print Inter-Task Communication
	/*
    kout << "\n*******************" << endl;
	kout << "Inter-Task Communication Matrix\nLeft column is sender, the others are receiving tasks" << endl;
    kout << "*******************\n\t";
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout <<  taskStrings[i] << "\t";
	}
	kout << endl;
	for (unsigned i = 0; i < NR_TASKS; i++) {
		kout << taskStrings[i] << "\t";
		for (unsigned j = 0; j < NR_TASKS; j++) {
			kout << INTER_TASK_RATIO[i][j] << "\t";
		}
		kout << endl;
	}
	kout << endl;
	*/

#ifndef QEMU
	// to better see results on PI wait at the end before rebooting
	micro_sec_wait(50000000);
#endif

	kout << "\n# of runnables in Time: " << count_trace('1') << "\t| Failed: " << count_trace('0') << "\n" << endl;

	test_finish();
	ShutdownMachine();

}
