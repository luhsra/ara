// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup arm
 * @brief ARM Private Timer
 */

#ifndef TIMER_H_
#define TIMER_H_

#include "platform.h"
#include "gic.h"
#include "stdint.h"

namespace arch {

	/** \brief Private Timer */
	class Timer {

		static uint32_t cntfrq;

	  public:
		/** \brief Initialize the Timer */
		static void init();

		/** \brief Stop the Timer */
		static void stop();

		/** \brief Generate periodic interrupt at given rate (in Hz) */
		static void set_periodic(uint16_t rate);

		/** \brief Acknowldge interrupt in ISR */
		static void ack_isr(void);
	};

}; // namespace arch

#endif /* TIMER_H_ */
