#include "spinlock.h"
#include <pthread.h>

using namespace os;

Spinlock::Spinlock(int id) 
: id(id)
{
    pthread_spin_init(&sl, PTHREAD_PROCESS_PRIVATE);
}
Spinlock::~Spinlock() {
    pthread_spin_destroy(&sl);
}

int Spinlock::lock() {
    return pthread_spin_lock(&sl);
}
int Spinlock::trylock() {
    return pthread_spin_trylock(&sl);
}
int Spinlock::unlock() {
    return pthread_spin_unlock(&sl);
}