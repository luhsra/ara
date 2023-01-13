#include "guard.h"
#include "output.h"
#include "machine.h"

Guard guard;

void Guard::enter()
{
    debug_core << "entering" << endl;

    Machine::disable_interrupts();

    active[arch::get_cpuid()] = true;

    Machine::enable_interrupts();
    pthread_mutex_lock(&mutex);

    debug_core << "entered" << endl;
}

void Guard::leave()
{
    debug_core << "leaving" << endl;

    pthread_mutex_unlock(&mutex);

    active[arch::get_cpuid()] = false;
}