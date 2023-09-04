// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "spinlock.h"

#include <errno.h>
#include <pthread.h>

using namespace os;

Spinlock::Spinlock(int id) : id(id) { pthread_spin_init(&sl, PTHREAD_PROCESS_PRIVATE); }
Spinlock::~Spinlock() { pthread_spin_destroy(&sl); }

StatusType Spinlock::lock() {
	int rc = pthread_spin_lock(&sl);
	if (rc == 0) {
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
		return E_OK;
	}
}
StatusType Spinlock::unlock() {
	int rc = pthread_spin_unlock(&sl);
	if (rc == 0) {
		return E_OK;
	}
	return E_NOT_OK;
}