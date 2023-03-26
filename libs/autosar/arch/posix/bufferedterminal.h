#ifndef __BUFFEREDTERMINAL_H__
#define __BUFFEREDTERMINAL_H__


#include "colorterminal.h"
#include <stdint.h>
#include "hardware_threads.h"
#include <cstring>
#include <pthread.h>

class BufferedTerminal : public Terminal {
	char buf[128] = {0};
	int idx = 0;
	bool printcpu;

public:
    BufferedTerminal(Terminal::port_t port = STDOUT, bool printcpu=true)
	: Terminal(port), printcpu(printcpu)
	{};

	void clear(){};

	virtual void putchar(char character) override {
		if (printcpu) {
			if (idx == 0) {
				buf[idx++] = '0' + arch::get_cpuid();
				buf[idx++] = '-';
			}
		}
		buf[idx++] = character;

		if (character == '\n') {
			write(m_channel, &buf, idx);
			memset(buf, 0, sizeof(buf));
			idx = 0;
		}
	}

};


#endif
