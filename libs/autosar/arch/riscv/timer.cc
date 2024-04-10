#include "timer.h"
#include "machine.h"
#include "os/counter.h"
#include "output.h"
#include "fdt.h"


namespace arch {
    volatile uint64_t *mtime;
uint64_t Timer::timebase_frequency;
unsigned Timer::interval;

void Timer::init(unsigned interval_ms) {
	interval = interval_ms;
	reload();
    // Enable the timer interrupt
	set_csr(CSR_MIE, MIP_MTIP);
}

void Timer::reload() {
	uintptr_t time = *mtime;
	*HLS()->timecmp = time + (timebase_frequency/1000) * interval;
}

void Timer::tick() {
	reload();
	os::Counter::tick();
}


}
