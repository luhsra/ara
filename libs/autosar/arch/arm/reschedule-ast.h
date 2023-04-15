// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

/**
 * @file
 * @ingroup i386
 * @brief i386 reschedule AST interface
 */

#ifndef __RESCHEDULE_AST_H__
#define __RESCHEDULE_AST_H__

#include "gic.h"
#include "os/util/inline.h"

namespace arch {

	/** \brief Request the reschedule AST to run after all other interrupts compelete. */
	forceinline void request_reschedule_ast() {
		// reset save_sp to detect IRQ from non-userspace in idt.S
		// save_sp = 0;

		GIC::trigger(IRQ_RESCHEDULE);
	}

} // namespace arch

#endif // __RESCHEDULE_AST_H__
