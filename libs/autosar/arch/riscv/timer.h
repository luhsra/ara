#ifndef __OSEK_V_TIMER_H__
#define __OSEK_V_TIMER_H__

#include "arch/generic/stdint.h"

#define CLINT_TIMER_OFFSET 0xbff8
#define MTIMECMP_BASE 0x4000

// Not sure where this timer comes from, but it should
//  be 1000 to trigger alarms correctly in automotive benchmark
// #define TIMER_FREQ 100000
#define TIMER_FREQ 1000



namespace arch {
    extern volatile uint64_t *mtime;


    struct Timer {
        static void init(unsigned interval_ms = 1000);
        static void reload();
        static void tick();

        static unsigned interval;
        static uint64_t timebase_frequency;
    };
}

#endif
