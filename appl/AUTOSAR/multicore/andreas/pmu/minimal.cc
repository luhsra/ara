#include "autosar/os.h"
#include "pmu.h"
#include "test/test.h"

DeclareTask(T00);

void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		//StartCore(OS_CORE_ID_1, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T00) {
	arch::PMU::start();
	arch::PMU::trace_counter0();
    arch::PMU::trace_cycles();

	test_trace('a');

	arch::PMU::trace_counter0();
	arch::PMU::trace_cycles();
	arch::PMU::stop();
	arch::PMU::print_counter0();
	arch::PMU::print_cycles();

	int cycles = arch::PMU::get_cycles();
	test_ne(cycles, 0);
	test_finish();
	ShutdownOS(E_OK);
}
