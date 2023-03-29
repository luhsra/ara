/**
 * @file
 * @ingroup posix
 * @brief Architecture-specific startup code
 */

#include "itimer.h"
#include "dispatch.h"
#include "spinlock.h"

/** Initialisation stub for generic startup code */
extern "C" void init_generic();

using namespace arch;

bool initialized = false;
os::Spinlock init_lock;

//!< i386 specific startup code
extern "C" void arch_startup()
{
    init_lock.lock();

    if (!initialized) {
        arch::init_cpuid();
        // global constructors habe been are already called before main.

        Machine::init();

        Dispatcher::init();

        // setup timer
        //ITimer::init();


        // Proceed to generic initialisation
        init_generic();
        initialized = true;
    }


    init_lock.unlock();
}
