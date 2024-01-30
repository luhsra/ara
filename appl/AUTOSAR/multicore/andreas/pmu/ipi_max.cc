#include "autosar/os.h"

#define PMU_TRACE_C
#include "pmu.h"
#include "test/test.h"


DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);

_Atomic(bool) ready = false;
volatile int result = 0;

int is_prime(int number) {
    if (number <= 1) {
        return 0; // 0 and 1 are not prime
    }

    for (int i = 2; i <= number; ++i) {
        if (number % i == 0) {
            return 0; // not prime
        }
    }

    return 1; // prime
}

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) { //high priority
	test_trace('0');
	arch::PMU::start();
	arch::PMU::trace_cycles();
    ready = true;
    
    // do sth long running
    for (int i = 0; i < 1000; i++) {
        result = is_prime(i);
    }
	arch::PMU::trace_cycles();
    arch::PMU::stop();

    ready = false;
    // wait for core 1 to stop sending IPIs
    while(!ready){
        Machine::nop();
    }
	arch::PMU::print_cycles();
	test_trace('2');
	test_trace_assert("012");
	test_finish();
    ShutdownMachine();

}

TASK(T01) {
	TerminateTask();
}

TASK(T10) {
    // wait for core 0 to start measuring
    while (!ready) {
		Machine::nop();
	}
	test_trace('1');

    // IPI bombing
    int k = 0;
	while (ready) {
        if (k == 0) {
            ActivateTask(T01);
            k++;
        }
        Machine::nop();
    }
    kout << endl;
    kout << "val[2]=" << k << endl;
    ready = true;
    TerminateTask();
}

