#include "machine.h"
#include "frontend.h"
#include "output.h"
#include "htif.h"



HTIFOutputStream kout;
HTIFOutputStream debug;

void HTIFOutputStream::putchar(char ch) {
	// bool enabled = Machine::disable_interrupts();
    htif_console_putchar(ch);
	// if (enabled)
	//	Machine::enable_
}
