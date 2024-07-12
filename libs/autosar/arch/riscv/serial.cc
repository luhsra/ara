#include "serial.h"
#include "hardware_threads.h"
#include "os/spinlock.h" // Include the header file that defines the Spinlock class

#define UART        0x10000000
#define UART_THR    (uint8_t*)(UART+0x00) // THR:transmitter holding register
#define UART_LSR    (uint8_t*)(UART+0x05) // LSR:line status register
#define UART_LSR_EMPTY_MASK 0x40          // LSR Bit 6: Transmitter empty; both the THR and LSR are empty



Serial::Serial() {
}

void Serial::putchar(char c) {
	
	while ((*UART_LSR & UART_LSR_EMPTY_MASK) == 0);
	*UART_THR = c;
	
	return;
}

void Serial::puts(const char* data) {
	//Spinlock lock;


	while (*data) putchar(*data++);
	
}

