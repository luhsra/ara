#include "serial.h"
#include "machine.h"
#include "hardware_threads.h"
#include "os/spinlock.h" // Include the header file that defines the Spinlock class

#ifndef UART // use default UART value(e.g. QEMU)
#define UART        0x10000000
#define UART_WAIT
#endif

#define UART_THR    (uint8_t*)(UART+0x00) // THR:transmitter holding register
#define UART_LSR    (uint8_t*)(UART+0x05) // LSR:line status register
#define UART_LSR_EMPTY_MASK 0x40          // LSR Bit 6: Transmitter empty; both the THR and LSR are empty



Serial::Serial() {
}

void Serial::putchar(char c) {

#ifdef UART_WAIT
	while ((*UART_LSR & UART_LSR_EMPTY_MASK) == 0);
#else
	for (long long i = 0; i < (1<<12); i++) {Machine::nop();} // experimentally configured delay
#endif
	*UART_THR = c;

	return;
}

void Serial::puts(const char* data) {
	while (*data) putchar(*data++);
	
}

