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

bool initialized = false;
pthread_mutex_t init = PTHREAD_MUTEX_INITIALIZER;

//!< i386 specific startup code
extern "C" void arch_startup()
{
    pthread_mutex_lock(&init);

    if (!initialized) {
        // global constructors habe been are already called before main.

        Machine::init();

        Dispatcher::init();

        // setup timer
        //ITimer::init();

        arch::init_cpuid();

        // Proceed to generic initialisation
        init_generic();
        initialized = true;
    }

    pthread_mutex_unlock(&init);
}
