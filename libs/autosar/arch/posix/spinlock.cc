#include "spinlock.h"
#include <pthread.h>
#include <errno.h>

using namespace os;

Spinlock::Spinlock(int id) 
: id(id)
{
    pthread_spin_init(&sl, PTHREAD_PROCESS_PRIVATE);
}
Spinlock::~Spinlock() {
    pthread_spin_destroy(&sl);
}

StatusType Spinlock::lock() {
    int rc = pthread_spin_lock(&sl);
    if (rc == 0) {
        // todo store somewhere for reschedule
        return E_OK;
    }
    return E_NOT_OK;
}
StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
    int rc = pthread_spin_trylock(&sl);
    if (rc == EBUSY) {
        *success = TRYTOGETSPINLOCK_NOSUCCESS;
        return E_OK;
    } else if (rc != 0) {
        *success = TRYTOGETSPINLOCK_NOSUCCESS;
        return E_NOT_OK;
    } else {
        *success = TRYTOGETSPINLOCK_SUCCESS;
        // todo store somewhere for reschedule
        return E_OK;
    }
}
StatusType Spinlock::unlock() {
    int rc = pthread_spin_unlock(&sl);
    if (rc == 0) {
        // todo store somewhere for reschedule
        return E_OK;
    }
    return E_NOT_OK;
}