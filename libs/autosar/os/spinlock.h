// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef _SPINLOCK_H_
#define _SPINLOCK_H_

#include "osek_types.h"

#include <stdint.h>

namespace os {
	class Spinlock {
	  private:
		int sl;
		bool state;

	  public:
		const int id;
		Spinlock(const Spinlock&) = delete;
		Spinlock& operator=(const Spinlock&) = delete;
		//~Spinlock();

		Spinlock(const int id = 0);

		StatusType lock();
		StatusType trylock(TryToGetSpinlockType* success);
		StatusType unlock();
	};
} // namespace os

#endif
