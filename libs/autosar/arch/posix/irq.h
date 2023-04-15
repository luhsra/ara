// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef _POSIX_IRQ_H_
#define _POSIX_IRQ_H_

#include "hardware_threads.h"
#include "inline.h"

#include <signal.h>

#define SIGMAX 256

namespace arch {
	class IRQ {
		bool ast_requested[MAX_CPUS];
		int ast_level[MAX_CPUS];
		sigset_t full_mask;

	  public:
		typedef void (*irq_handler_t)(int);
		static const int IPISIG = SIGCHLD;

		IRQ();

		void set_handler(int signum, irq_handler_t gate);
		void enable(int signum);
		void disable(int signum);
		noinline void trigger_interrupt(int irq, int cpuid, bool sync = false);
		noinline void deliver_interrupt(int irq);

		void enable_interrupts(sigset_t* mask = nullptr);
		void disable_interrupts(sigset_t* oldmask = nullptr);
		void clear_interrupts();

		bool interrupts_enabled(int irq = 0);

		bool forceinline in_interrupt() { return ast_level[arch::get_cpuid()] > 0; }

		void request_ast() { ast_requested[arch::get_cpuid()] = true; }

	  private:
		static void guardian(int signum);

		irq_handler_t m_gate[SIGMAX];
	};

	extern IRQ irq;

}; // namespace arch

#endif /* _PIC_H */
