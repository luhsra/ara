#ifndef _SPINLOCK_H_
#define _SPINLOCK_H_

#include <stdint.h>
#include "osek_types.h"

namespace os {
class Spinlock {
private:
    int sl;
    bool state;

public:
    bool elide = false;
    const int id;
    Spinlock (const Spinlock&) = delete;
    Spinlock& operator= (const Spinlock&) = delete;

    Spinlock(const int id = 0);
    ~Spinlock();

    StatusType lock();
    StatusType trylock(TryToGetSpinlockType* success);
    StatusType unlock();
};
}

#endif
