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

const unsigned VERSION = 1;
/**
 * Test large number of runnables that get started in predifined periods
 * and allocate lables -> memory to them
 * FROM: REAL WORLD AUTOMOTIVE BENCHMARKS FOR FREE
 */

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


// # labels
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
const unsigned READ_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 4 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 10;
const unsigned WRITE_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE* 1 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 10;
const unsigned RW_ACCESSES_PER_RUNNABLE = AVAERAGE_LABEL_SIZE * 5 * (NUMBER_OF_LABELS / NUMBER_OF_RUNNABLES) / 10;
const unsigned SIZE_PER_RUNNABLE = READ_ACCESSES_PER_RUNNABLE + WRITE_ACCESSES_PER_RUNNABLE + RW_ACCESSES_PER_RUNNABLE;

uint8_t communication[NUMBER_OF_LABELS * AVAERAGE_LABEL_SIZE];
uint16_t memory_pos = 0;

// startup + control Task, loweest prio
TASK(SCHED1) {
	arch::Perf::start();
    kout << "V:" << VERSION << "Label Test w " << NUMBER_OF_RUNNABLES << " runnables + " << NUMBER_OF_LABELS << " Labels." << endl;
	// micro_sec_wait(30000000);
	test_trace('S');

	for (unsigned i = 0; i < RUNS; i++) {

		memory_pos = 0;
		uint32_t start_cycle = arch::Perf::get_cycles();

		if (i % PERIOD[0] == 0) {
			ActivateTask(MS1);
		}	
		if (i % PERIOD[1] == 0) {
			ActivateTask(MS2);
		}
		if (i % PERIOD[2] == 0) {
			ActivateTask(MS5);
		}
		if (i % PERIOD[3] == 0) {
			ActivateTask(MS10);
		}
		if (i % PERIOD[4] == 0) {
			ActivateTask(MS20);
		}
		if (i % PERIOD[5] == 0) {
			ActivateTask(MS50);
		}
		if (i % PERIOD[6] == 0) {
			ActivateTask(MS100);
		}
		if (i % PERIOD[7] == 0) {
			ActivateTask(MS200);
		}
		if (i % PERIOD[8] == 0) {
			ActivateTask(MS1000);
		}

		uint32_t end_cycle = arch::Perf::get_cycles();

		bool in_time = micro_sec_wait_upto(start_cycle, SCHEDUL_INTERVAL);
		in_time ? test_trace('1') : test_trace('0');

		/*
		kout << "t: " << 1000 * WAIT_FREQUENCE << " d: " << end_cycle - start_cycle << endl;	
		kout << "s: " << start_cycle << " e: " << end_cycle << endl;	
		kout << "Run: \t" << i << " | In time? " << in_time << "\n" << endl;
		*/
	}

	TerminateTask();
}

/* Idea: copy all data to local labels

	uint8_t local_labels[memory];

	for (unsigned i = 0; i < memory; i++) {
		local_labels[i] = communication[memory_pos + i];
	}

	// advance memory
	memory_pos += memory;


	//

	for (unsigned i = 0; i < memory; i++) {
		communication[memory_pos + i]++;
		kout << (uint16_t)communication[memory_pos + i] << endl;
	} 
 */

unsigned i = 0;
unsigned j = 0;

TASK(MS1) {
	const unsigned task_id = 0;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;


	communication[i] = j++;
	kout << "Prod: " << (uint16_t)communication[i] << endl; 
	

	micro_sec_wait(time);

	TerminateTask();
}
TASK(MS2) {
	const unsigned task_id = 1;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS5) {
	const unsigned task_id = 2;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	

	kout << "Consume: i= " << i << " " << (uint16_t)communication[i] << endl; 
	i++;
	j = 0;


	micro_sec_wait(RUNNABLES_PER100 * SHARE[2] * TIME[2]);
	//test_trace('5');
	TerminateTask();
}
TASK(MS10) {
	const unsigned task_id = 3;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS20) {
	const unsigned task_id = 4;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS50) {
	const unsigned task_id = 5;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS100) {
	const unsigned task_id = 6;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS200) {
	const unsigned task_id = 7;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}
TASK(MS1000) {
	const unsigned task_id = 8;
	// number of runs
	const unsigned runs = RUNNABLES_PER100 * SHARE[task_id];
	// calculation time
	const unsigned time = runs * TIME[task_id];
	// label size
	const unsigned memory = runs * SIZE_PER_RUNNABLE;
	
	micro_sec_wait(time);
	TerminateTask();
}

void PreIdleHook() {
	kout << "TASKPERIOD| NUMBER OF RUNNABLES | EXPECTED RUNTIME" << endl;
	kout << "MS1       | " << RUNNABLES_PER100 * SHARE[0] << "x \t\t| " << RUNNABLES_PER100 * SHARE[0] * TIME[0] << "us" << endl;
    kout << "MS2       | " << RUNNABLES_PER100 * SHARE[1] << "x \t\t| " << RUNNABLES_PER100 * SHARE[1] * TIME[1] << "us" << endl;
    kout << "MS5       | " << RUNNABLES_PER100 * SHARE[2] << "x \t\t| " << RUNNABLES_PER100 * SHARE[2] * TIME[2] << "us" << endl;
    kout << "MS10      | " << RUNNABLES_PER100 * SHARE[3] << "x \t\t| " << RUNNABLES_PER100 * SHARE[3] * TIME[3] << "us" << endl;
    kout << "MS20      | " << RUNNABLES_PER100 * SHARE[4] << "x \t\t| " << RUNNABLES_PER100 * SHARE[4] * TIME[4] << "us" << endl;
    kout << "MS50      | " << RUNNABLES_PER100 * SHARE[5] << "x \t\t| " << RUNNABLES_PER100 * SHARE[5] * TIME[5] << "us" << endl;
    kout << "MS100     | " << RUNNABLES_PER100 * SHARE[6] << "x \t\t| " << RUNNABLES_PER100 * SHARE[6] * TIME[6] << "us" << endl;
    kout << "MS200     | " << RUNNABLES_PER100 * SHARE[7] << "x \t\t| " << RUNNABLES_PER100 * SHARE[7] * TIME[7] << "us" << endl;
    kout << "MS1000    | " << RUNNABLES_PER100 * SHARE[8] << "x \t\t| " << RUNNABLES_PER100 * SHARE[8] * TIME[8] << "us" << endl;

	kout << "\n# in Time: " << count_trace('1') << "\t|\tFailed: " << count_trace('0') << "\n" << endl;

	test_trace_dump();
	test_finish();
	
	// micro_sec_wait(30000000);

	ShutdownMachine();

}
