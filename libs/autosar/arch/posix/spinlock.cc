#include "spinlock.h"
#include <pthread.h>
#include <errno.h>
#include "output.h"

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
    if (elide) {
        debug_core << "Spinlock::lock() elided" << endl;
        return E_OK;
    }

    int rc = pthread_spin_lock(&sl);
    if (rc == 0) {
        return E_OK;
    }
    return E_NOT_OK;
}
StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
    if (elide) {
        debug_core << "Spinlock::trylock() elided" << endl;
        return E_OK;
    }

    int rc = pthread_spin_trylock(&sl);
    if (rc == EBUSY) {
        *success = TRYTOGETSPINLOCK_NOSUCCESS;
        return E_OK;
    } else if (rc != 0) {
        *success = TRYTOGETSPINLOCK_NOSUCCESS;
        return E_NOT_OK;
    } else {
        *success = TRYTOGETSPINLOCK_SUCCESS;
        return E_OK;
    }
}
StatusType Spinlock::unlock() {
    if (elide) {
        elide = false;
        debug_core << "Spinlock::unlock() elided" << endl;
        return E_OK;
    }

    int rc = pthread_spin_unlock(&sl);
    if (rc == 0) {
        return E_OK;
    }
    return E_NOT_OK;
}