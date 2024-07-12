#include "timer.h"
#include "machine.h"
#include "os/counter.h"
#include "output.h"



namespace arch {
    volatile uint64_t *mtime = (uint64_t *) (CLINT_BASE + CLINT_TIMER_OFFSET + 8 * arch::get_cpuid());

	uint64_t Timer::timebase_frequency = TIMER_FREQ;
	unsigned Timer::interval;

void Timer::init(unsigned interval_ms) {

	interval = interval_ms;
	reload();
	set_csr(CSR_MIE, MIP_MTIP);
}

void Timer::reload() {

	uintptr_t time = *mtime;

	*HLS()->timecmp = time + (timebase_frequency/1000) * interval;
	//debug_core << "Time" << endl;
}

void Timer::tick() {
	
	reload();
	//kout << "Timer tick" << endl;
	os::Counter::tick();
}

}
