// SPDX-FileCopyrightText: 2013-2014 Florian Lukas <florian.lukas@gmail.com>
// SPDX-FileCopyrightText: 2013-2014 Martin Hoffmann <hoffmann@cs.fau.de>
// SPDX-FileCopyrightText: 2013-2019 Christian Dietrich <christian.dietrich@informatik.uni-erlangen.de>
// SPDX-FileCopyrightText: 2023 Andreas Kässens
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef __BUFFEREDTERMINAL_H__
#define __BUFFEREDTERMINAL_H__

#include "colorterminal.h"
#include "hardware_threads.h"

#include <cstdio>
#include <cstring>
#include <pthread.h>
#include <stdint.h>

#define BUF_LEN 80

class BufferedTerminal : public Terminal {
	char buf[BUF_LEN] = {0};
	int idx = 0;
	bool printcpu;

  public:
	BufferedTerminal(Terminal::port_t port = STDERR, bool printcpu = true) : Terminal(port), printcpu(printcpu){};

	void clear(){};

	virtual void putchar(char character) override {
		if (printcpu) {
			if (idx == 0) {
				int cpuid = arch::get_cpuid();
				int phycpu = sched_getcpu();
				buf[idx++] = cpuid + (cpuid > 9 ? 55 : '0');
				buf[idx++] = '-';
				buf[idx++] = phycpu + (phycpu > 9 ? 55 : '0');
				buf[idx++] = ':';
			}
		}
		buf[idx++] = character;

		if (idx == BUF_LEN - 1) {
			character = '\n';
			buf[idx++] = character;
		}

		if (character == '\n') {
			write(m_channel, &buf, idx);
			memset(buf, 0, sizeof(buf));
			idx = 0;
		}
	}
};

#endif
