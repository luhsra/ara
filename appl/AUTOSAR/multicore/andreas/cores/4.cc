#include "autosar/os.h"
#include "test/test.h"

#include <sys/sysinfo.h>
void start() {
	StatusType rv;
	switch (GetCoreID()) {
	case OS_CORE_ID_MASTER:
		StartCore(OS_CORE_ID_1, &rv);
		StartCore(OS_CORE_ID_2, &rv);
		StartCore(OS_CORE_ID_3, &rv);
	default:
		StartOS(0);
	}
}

TEST_MAKE_OS_MAIN(start())

TASK(T0) {
	int cores = GetNumberOfActivatedCores();
	test_init();
	test_start();
	int expected_cores = get_nprocs() < 4 ? get_nprocs() : 4;
	test_eq(cores, expected_cores);
	test_positive_tests_eq(1);
	test_finish();
	ShutdownAllCores(E_OK);
}
