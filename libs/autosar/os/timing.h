#ifndef __OS_TIMING_H
#define __OS_TIMING_H

#include "stdint.h"

#define STRINGIFY(a) #a

#if defined(CONFIG_ARCH_PATMOS)
extern "C" {
extern void timing_start(int circuit);
extern uint64_t timing_end(int circuit);
extern int timing_print();
}
#define timing_dump() asm volatile("trap 2")
#define timing_loop_bound(low, high) _Pragma(STRINGIFY(loopbound min low max high))
#else
#define timing_start(a) 0
#define timing_end(a) 0
#define timing_dump()                                                                                                  \
	do {                                                                                                               \
		Machine::shutdown();                                                                                           \
	} while (0)
#define timing_loop_bound(low, high)
#define timing_print()
#endif

#define TIMING_POINT_NO_INTERRUPTS_IN_BLOCK 0x200
#define TIMING_POINT_IS_HIGHEST_PRIO 0x400

#define TIMING_POINT_STOP_BEFORE 0x100

#define TIMING_POINT_START_INTERRUPT_IN_BLOCK 0x100
#define TIMING_POINT_START_INTERRUPT_FROM_IDLE 0x800

#define GENERATE_TIME_CONSUMER(name, amount)                                                                           \
	extern "C" int noinline name() {                                                                                   \
		volatile int i = 0;                                                                                            \
		timing_loop_bound(amount, amount) for (; i < amount; i++){};                                                   \
		return i;                                                                                                      \
	}

#define TIMING_MAKE_OS_MAIN(body)                                                                                      \
	void os_main(void) { body; }

#endif
