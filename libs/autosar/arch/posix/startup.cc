/**
 * @file
 * @ingroup posix
 * @brief Architecture-specific startup code
 */

#include "itimer.h"
#include "dispatch.h"

/** Initialisation stub for generic startup code */
//extern "C" void init_generic();
extern "C" void os_main();

using namespace arch;

//!< i386 specific startup code
void arch_startup()
{
    // global constructors habe been are already called before main.

    Machine::init();

    Dispatcher::init();

    // setup timer
    ITimer::init();

	// Proceed to generic initialisation
	//init_generic();
    os_main();
}

//!< POSIX startup obviously in "main"
//!< Here, all constructors are already called.

int main(int argc, char**argv){
    (void) argc;
    (void) argv;
    arch_startup();
    return 0;
}
