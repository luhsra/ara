#include "autosar/os.h"
#include "perf.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T01);
DeclareTask(T10);

bool ready = false;

extern char _cachetest_start, _cachetest_end;

const int cachetest_start = (int) &_cachetest_start;
const int cachetest_end = (int) &_cachetest_start + (int) ((1<<20));

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

void cache_test() {
	volatile unsigned char load;
	for (int i = cachetest_start; i < cachetest_end; i += 0x40 ) {
		load = * (unsigned char*) i;
	}

	arch::Perf::trace_counter0();
}

TASK(T00) {
	test_trace('0');
	arch::Perf::start();
	arch::Perf::trace_counter0();
	for ( int i = 0; i < 8; i++)
		cache_test();

	ready = true;
	while (1) {
		Machine::nop();
	}
	TerminateTask();
}

TASK(T01) {
	for ( int i = 0; i < 8; i++)
		cache_test();

	arch::Perf::stop();
	arch::Perf::print_counter0();
	test_trace('1');
	test_trace_assert("01");
	test_finish();
	ShutdownAllCores(E_OK);
}

TASK(T10) {
	while (!ready) {
		Machine::nop();
	}
	ActivateTask(T01);
	while (1) {
		Machine::nop();
	}
}

