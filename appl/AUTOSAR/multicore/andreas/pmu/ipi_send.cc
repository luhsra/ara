#include "autosar/os.h"
#include "pmu.h"
#include "test/test.h"

DeclareTask(T00);
DeclareTask(T10);

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

TASK(T00) {
	arch::PMU::start();
	// checkpoint 0
	arch::PMU::trace_cycles();
	ActivateTask(T10);
	// checkpoint 5
	arch::PMU::trace_cycles();
	arch::PMU::stop();
	arch::PMU::print_cycles();
	ShutdownAllCores(E_OK);
}

TASK(T10) {
	TerminateTask();
}
