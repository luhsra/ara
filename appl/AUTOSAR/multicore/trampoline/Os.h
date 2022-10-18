#include "autosar/os.h"

// fake functions for trampoline
#define SCHEDULING_CHECK_INIT(a)
#define SCHEDULING_CHECK_AND_EQUAL_INT(a, b, c)

using CoreFunc = void (*)();
using TestRef =

void TestRunner_runTest(TestRef t) {t();}
CoreFunc new_TestFixture(char*, CoreFunc func) {return func;}


EMB_UNIT_TESTFIXTURES
#define EMB_UNIT_TESTCALLER(fix)

