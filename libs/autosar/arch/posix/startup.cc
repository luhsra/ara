/**
 * @file
 * @ingroup posix
 * @brief Architecture-specific startup code
 */

#include "itimer.h"
#include "dispatch.h"
#include <pthread.h>

/** Initialisation stub for generic startup code */
extern "C" void init_generic();

using namespace arch;

//!< i386 specific startup code
extern "C" void arch_startup()
{
    // global constructors habe been are already called before main.

    Machine::init();

    Dispatcher::init();

    // setup timer
    //ITimer::init();

    arch::init_cpuid();

    // Proceed to generic initialisation
    init_generic();
}
