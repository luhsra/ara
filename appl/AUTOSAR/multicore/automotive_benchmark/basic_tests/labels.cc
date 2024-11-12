#include "os.h"
#include "test/test.h"
#include "arch/arm/platforms/raspberry/perf.cc"

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

const char* taskStrings[] = {"MS1", "MS2", "MS5", "MS10", "MS20", "MS50", "MS100", "MS200", "MS1000"};
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

// how often the scheduler gets started
const unsigned RUNS = 1000;
// start new runnables each ms = 1000um
const unsigned SCHEDUL_INTERVAL = 1000;

// #runnables-> how many runnables are 1% of system
const unsigned NUMBER_OF_RUNNABLES = 1000;
// -> how many runnables are 1% of system
const unsigned RUNNABLES_PER100 = NUMBER_OF_RUNNABLES / 100;

// Predifined periods to trigger runnables (in ms)
const unsigned PERIOD[] = {1, 2, 5, 10, 20, 50, 100, 200, 1000};
// const unsigned PERIOD[] = {1, 2, 7, 11, 23, 51, 104, 199, 1003};
// Share of these periods (in %)
const unsigned SHARE[] = {3, 2, 2, 25, 25, 3, 20, 1, 4};
// Average execution time in microseconds (in us)
const unsigned TIME[] = {5, 5, 12, 11, 9, 18, 11, 3, 1};


// labels
const unsigned NUMBER_OF_LABELS = 10000;
const unsigned LABELS_PER1000 = NUMBER_OF_LABELS/1000;
// 1, 2, 4, (5-)8, (9-)16, (17-)32, (33-)64, >64 -> 128 	Bytes
/*const unsigned LABEL_SIZE[] = 	{1, 	2, 	 4, 8,  16, 32, 64, 128};
const unsigned LABEL_SHARE[] = 	{350, 490, 130, 8, 13,  5,  2, 2};
const unsigned LABEL_AREA = LABELS_PER1000*LABEL_SHARE[0]*LABEL_SIZE[0] + LABELS_PER1000*LABEL_SHARE[1]*LABEL_SIZE[1]
						 +  LABELS_PER1000*LABEL_SHARE[2]*LABEL_SIZE[2] + LABELS_PER1000*LABEL_SHARE[3]*LABEL_SIZE[3] 
						 +  LABELS_PER1000*LABEL_SHARE[4]*LABEL_SIZE[4] + LABELS_PER1000*LABEL_SHARE[5]*LABEL_SIZE[5]
						 +  LABELS_PER1000*LABEL_SHARE[6]*LABEL_SIZE[6] + LABELS_PER1000*LABEL_SHARE[7]*LABEL_SIZE[7];
*/
// (35+2*49+4*13+8*0.8+16*1.3+32*0.5+64*0.2+128*0.2 )/ 100 -> 2.66 Byte
const unsigned AVAERAGE_LABEL_SIZE = 3;
// Of that: 40% read, 10% write, 50% read/write
const unsigned READ_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 40 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned WRITE_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE* 10 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned RW_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 50 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 100;
const unsigned SIZE_PER_RUNNABLE = READ_ACCESSES_PER_RUNNABLE + WRITE_ACCESSES_PER_RUNNABLE + RW_ACCESSES_PER_RUNNABLE;

uint8_t communication[NUMBER_OF_LABELS * AVAERAGE_LABEL_SIZE];
uint16_t memory_pos = 0;
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
};

/**
 ********************* SCHEDULER *********************
 */

// startup + control Task, loweest prio
unsigned cycle = 0;
TASK(SCHED1) {
	arch::Perf::start();
    kout << "********************" << endl;
	kout << "Label Test w\t" << NUMBER_OF_RUNNABLES << "\tRunnables and\t" << NUMBER_OF_LABELS << "\tLabels." << endl;
    kout << "********************" << endl;

	// optionaly wait
	// micro_sec_wait(30000000);

	for (; cycle < RUNS; cycle++) {

		uint32_t start_cycle = arch::Perf::get_cycles();

		if (cycle % PERIOD[MS1_id] == 0) {
			memory_pos = MS1_mem;
			ActivateTask(MS1);
		}	
		if (cycle % PERIOD[MS2_id] == 0) {
			memory_pos = MS2_mem;
			ActivateTask(MS2);
		}
		if (cycle % PERIOD[MS5_id] == 0) {
			memory_pos = MS5_mem;
			ActivateTask(MS5);
		}
		if (cycle % PERIOD[MS10_id] == 0) {
			memory_pos = MS10_mem;
			ActivateTask(MS10);
		}
		if (cycle % PERIOD[MS20_id] == 0) {
			memory_pos = MS20_mem;
			ActivateTask(MS20);
		}
		if (cycle % PERIOD[MS50_id] == 0) {
			memory_pos = MS50_mem;
			ActivateTask(MS50);
		}
		if (cycle % PERIOD[MS100_id] == 0) {
			memory_pos = MS100_mem;
			ActivateTask(MS100);
		}
		if (cycle % PERIOD[MS200_id] == 0) {
			memory_pos = MS200_mem;
			ActivateTask(MS200);
		}
		if (cycle % PERIOD[MS1000_id] == 0) {
			memory_pos = MS1000_mem;
			ActivateTask(MS1000);
		}

		/*
		Wäre sehr viel schöner, der Name MSX wird oben bereits definiert
		for (task_id id = MS1_id; id < MS_LAST_id; id = task_id(id+1)) {
			if (cycle % PERIOD[id] == 0) {
				memory_pos = memory_position(id);
				kout << taskStrings[id] << endl;
				ActivateTask(taskStrings[id]);
				ActivateTask(id);	// geht nicht
		}	
		*/

		uint32_t end_cycle = arch::Perf::get_cycles();

		bool in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');

		if (!in_time) {
			kout << "Cycle:\t" << cycle << "\tfailed overall timing" << endl;
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
	for (unsigned i = 0; i < read_writes; memory_pos++, i++) {
		tmp = communication[memory_pos] + 1;
		communication[memory_pos] = tmp;
	}

	
	bool in_time = micro_sec_wait_upto(start_cycle, time);
	if (!in_time) {
		kout << "Cycle:\t" << cycle << "\t" << taskStrings[task] << "\ttook longer because of memory" << endl;
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
    kout << "\n********************" << endl;
    kout << "END - Test w\t" << NUMBER_OF_RUNNABLES << "\tRunnables and\t" << NUMBER_OF_LABELS << "\tLabels." << endl;
    kout << "********************" << endl;
	kout << "\n\nTASKPERIOD| NUMBER OF RUNNABLES | EXPECTED RUNTIME" << endl;
	for (unsigned i = 0; i < sizeof(taskStrings) / sizeof(taskStrings[0]); i++) {
		kout << taskStrings[i] << "\t\t| " << RUNNABLES_PER100 * SHARE[i] << "x \t\t| " << RUNNABLES_PER100 * SHARE[i] * TIME[i] << "us" << endl;
	}
	
	kout << "\n# in Time: " << count_trace('1') << "\t|\tFailed: " << count_trace('0') << "\n" << endl;
	
	// optionaly wait
	// micro_sec_wait(30000000);

	test_finish();
	ShutdownMachine();

}
