// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "spinlock.h"

#include "output.h"

using namespace os;

Spinlock::Spinlock(int id) : id(id) { this->sl = 0; }

// Spinlock::~Spinlock() {}

StatusType Spinlock::lock() {
	int result = 1;

	// Loop until the lock is successfully acquired
	while (result) {
		asm volatile("ldrex %[result], [%[lock]]"
		             "\n\t"
		             "cmp %[result], #0"
		             "\n\t"
		             "beq 1f"
		             "\n\t"
		             "clrex"
		             "\n\t" // Clear exclusive access if the lock is already taken
		             "b   0f"
		             "\n\t"
		             "1:"
		             "\n\t"
		             "strex %[result], %[value], [%[lock]]"
		             "\n\t"
		             "0:"
		             : [result] "=&r"(result)
		             : [lock] "r"(&this->sl), [value] "r"(1)
		             : "cc", "memory");
	}

	return E_OK;
}
StatusType Spinlock::trylock(TryToGetSpinlockType* success) {
	int result = 0;

	asm volatile("ldrex %[result], [%[lock]]"
	             "\n\t"
	             "cmp %[result], #0"
	             "\n\t"
	             "beq 1f"
	             "\n\t"
	             "clrex"
	             "\n\t" // Clear exclusive access if the lock is already taken
	             "b   0f"
	             "\n\t"
	             "1:"
	             "\n\t"
	             "strex %[result], %[value], [%[lock]]"
	             "\n\t"
	             "0:"
	             : [result] "=&r"(result)
	             : [lock] "r"(&this->sl), [value] "r"(1)
	             : "cc", "memory");

	if (!result)
		*success = TRYTOGETSPINLOCK_SUCCESS;
	else
		*success = TRYTOGETSPINLOCK_NOSUCCESS;

	return E_OK;
}

StatusType Spinlock::unlock() {
	// Simply store 0 to the lock to release it
	asm volatile("str %[value], [%[lock]]" : : [lock] "r"(&this->sl), [value] "r"(0) : "memory");

	return E_OK;
}