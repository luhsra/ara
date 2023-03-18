/**
 * @file
 * @ingroup posix
 * @brief Architecture-specific startup code
 */

#include "itimer.h"
#include "dispatch.h"

/** Initialisation stub for generic startup code */
extern "C" void init_generic();

using namespace arch;

//!< i386 specific startup code
extern "C" void arch_startup()
{
    // global constructors habe been are already called before main.

    /* set affinity to CPU 0*/
    cpu_set_t cpuset;
    pthread_t thread;
    thread = pthread_self();
    CPU_ZERO(&cpuset);
    CPU_SET(0, &cpuset);
    pthread_setaffinity_np(thread, sizeof(cpuset), &cpuset);

    Machine::init();

    Dispatcher::init();

    // setup timer
    //ITimer::init();

    arch::init_cpuid();

    // Proceed to generic initialisation
    init_generic();
}
