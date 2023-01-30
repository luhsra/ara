#ifndef _SPINLOCK_H_
#define _SPINLOCK_H_

namespace os {
class Spinlock {
private:
    int sl;

public:
    const int id;
    Spinlock (const Spinlock&) = delete;
    Spinlock& operator= (const Spinlock&) = delete;

    Spinlock(const int id);
    ~Spinlock();

    int lock();
    int trylock();
    int unlock();
};
}

#endif
