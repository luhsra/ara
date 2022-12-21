#ifndef __BUFFEREDTERMINAL_H__
#define __BUFFEREDTERMINAL_H__


#include "colorterminal.h"
#include <stdint.h>
#include "hardware_threads.h"
#include <cstring>
#include <pthread.h>

class BufferedTerminal : public ColorTerminal {
	char buf[128] = {0};
	int idx = 0;
	pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    char m_colorcode[sizeof("\033[0;3X;4Ym")]; //! set color in terminal: 3X = foreground, 4Y = background

public:
    BufferedTerminal(Terminal::port_t port = STDOUT) : ColorTerminal(port) {};

	void clear(){};

	virtual void putchar(char character) override {
		if (idx == 0) {
			buf[idx++] = '0' + arch::get_cpuid();
			buf[idx++] = ':';
		}
		buf[idx++] = character;
		
		if (character == '\n') {
			pthread_mutex_lock(&mutex);
			write(m_channel, &buf, idx);
			memset(buf, 0, sizeof(buf));
			idx = 0;
			pthread_mutex_unlock(&mutex);
		}
	}

};


#endif
