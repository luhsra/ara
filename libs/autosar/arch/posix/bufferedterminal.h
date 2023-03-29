#ifndef __BUFFEREDTERMINAL_H__
#define __BUFFEREDTERMINAL_H__


#include "colorterminal.h"
#include <stdint.h>
#include "hardware_threads.h"
#include <cstring>
#include <cstdio>
#include <pthread.h>

#define BUF_LEN 80

class BufferedTerminal : public Terminal {
	char buf[BUF_LEN] = {0};
	int idx = 0;
	bool printcpu;

public:
    BufferedTerminal(Terminal::port_t port = STDERR, bool printcpu=true)
	: Terminal(port), printcpu(printcpu)
	{};

	void clear(){};

	virtual void putchar(char character) override {
		if (printcpu) {
			if (idx == 0) {
				snprintf(buf, 5, "%x-%x:", arch::get_cpuid(), sched_getcpu());
				idx += 4;
			}
		}
		buf[idx++] = character;

		if (idx == BUF_LEN-1) {
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
