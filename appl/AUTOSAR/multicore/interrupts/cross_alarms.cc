/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"


DeclareTask(T11);

TEST_MAKE_OS_MAIN( StartOS(0) )

TASK(T11) {
	TerminateTask();
}
