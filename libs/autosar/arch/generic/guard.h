#ifndef __GUARD_H__
#define __GUARD_H__

#include "pthread.h"
#include "hardware_threads.h"

class Guard {
	Guard(const Guard&) = delete;
	Guard& operator=(const Guard&) = delete;

    pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
public:
    bool active[MAX_CPUS];

	Guard() {
		for (int i = 0; i < MAX_CPUS; i++) {
			active[i] = false;
		}
	}

    void enter();
	void leave();

	bool isActive() {
		return this->active[arch::get_cpuid()];
	}
};

extern Guard guard;

#endif
