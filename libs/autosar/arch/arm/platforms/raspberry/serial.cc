/**
 * @file
 * @ingroup ARM
 * @brief Serial driver implementation
 */
#include "serial.h"
#include "platform.h"
#include "hardware_threads.h"

extern "C" void PUT32(int, int);
extern "C" uint32_t GET32(int);

#define AUX_MU_BAUD(baud) ((CPU_FREQ_HZ/(baud*8))-1)

extern "C" void dummy (unsigned int)
{
    return 0;
}

Serial::Serial() {
}

extern "C" void serial_init() {
    unsigned int ra;

    PUT32(AUX_ENABLES,1);
    PUT32(AUX_MU_IER_REG,0);
    PUT32(AUX_MU_CNTL_REG,0);
    PUT32(AUX_MU_LCR_REG,3);
    PUT32(AUX_MU_MCR_REG,0);
    PUT32(AUX_MU_IER_REG,0);
    PUT32(AUX_MU_IIR_REG,0xC6);
    PUT32(AUX_MU_BAUD_REG,AUX_MU_BAUD(115200));
    ra=GET32(GPFSEL1);
    ra&=~(7<<12); //gpio14
    ra|=2<<12;    //alt5
    ra&=~(7<<15); //gpio15
    ra|=2<<15;    //alt5
    PUT32(GPFSEL1,ra);
    PUT32(GPPUD,0);
    for(ra=0;ra<150;ra++) dummy(ra);
    PUT32(GPPUDCLK0,(1<<14)|(1<<15));
    for(ra=0;ra<150;ra++) dummy(ra);
    PUT32(GPPUDCLK0,0);
    PUT32(AUX_MU_CNTL_REG,3);

    PUT32(AUX_MU_IO_REG,arch::get_cpuid()+'0');
}

void Serial::putchar(char c) {
    while(1)
    {
        if(GET32(AUX_MU_LSR_REG)&0x20) break;
    }
    PUT32(AUX_MU_IO_REG,c);
}

void Serial::puts(const char* data) {
	while(*data) {
        Serial::putchar(*data++);
    }
}
