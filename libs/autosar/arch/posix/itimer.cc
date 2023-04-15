// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup posix
 * @brief POSIX Timer implementation
 */

#include "itimer.h"

#include "machine.h"
#include "os/counter.h"

#include <pthread.h>
#include <signal.h>
#include <sys/time.h>

namespace arch {

	/** \brief Timer signal handler */
	void timer_handler(__attribute__((unused)) int signum) { os::Counter::tick(); }

	void ITimer::init() {
		arch::irq.set_handler(SIGALRM, timer_handler);
		arch::irq.enable(SIGALRM);

		// generate signal @ 1 kHz
		set_periodic(1000);
	}

	void ITimer::set_periodic(uint16_t rateHz) {

		timer_t timerid;
		struct sigevent sev;
		struct itimerspec its;
		long long freq_nanosecs;

		/**
		 * SIGEV_THREAD_ID is Linux only
		 * setitimer cannot be used because it will distribute signals to random threads
		 */
		sev.sigev_notify = SIGEV_THREAD_ID;
		sev._sigev_un._tid = gettid();
		sev.sigev_signo = SIGALRM;
		sev.sigev_value.sival_ptr = &timerid;
		timer_create(CLOCK_REALTIME, &sev, &timerid);

		freq_nanosecs = 1e9 / rateHz;
		its.it_value.tv_sec = freq_nanosecs / 1000000000;
		its.it_value.tv_nsec = freq_nanosecs % 1000000000;
		its.it_interval.tv_sec = its.it_value.tv_sec;
		its.it_interval.tv_nsec = its.it_value.tv_nsec;
		timer_settime(timerid, 0, &its, NULL);
	}

}; // namespace arch
