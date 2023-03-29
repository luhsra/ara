#include "autosar/os.h"
#include "test/test.h"

void start()
{
    StatusType rv;
    switch(GetCoreID()) {
    case OS_CORE_ID_MASTER:
        StartCore(OS_CORE_ID_1, &rv);
        StartCore(OS_CORE_ID_2, &rv);
        StartCore(OS_CORE_ID_3, &rv);
        StartCore(OS_CORE_ID_4, &rv);
        StartCore(OS_CORE_ID_5, &rv);
        StartCore(OS_CORE_ID_6, &rv);
        StartCore(OS_CORE_ID_7, &rv);
        StartCore(OS_CORE_ID_8, &rv);
        StartCore(OS_CORE_ID_9, &rv);
        StartCore(OS_CORE_ID_10, &rv);
        StartCore(OS_CORE_ID_11, &rv);
        StartCore(OS_CORE_ID_12, &rv);
        StartCore(OS_CORE_ID_13, &rv);
        StartCore(OS_CORE_ID_14, &rv);
        StartCore(OS_CORE_ID_15, &rv);
    default:
        StartOS(0);
    }
}

TEST_MAKE_OS_MAIN(start())

TASK(T0) {
    int cores = GetNumberOfActivatedCores();
    test_init();
    test_start();
    test_eq(cores, 16);
    test_positive_tests_eq(1);
    test_finish();
    ShutdownAllCores(E_OK);
}
