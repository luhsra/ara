#ifndef __OSEK_V_TIMER_H__
#define __OSEK_V_TIMER_H__

#include "arch/generic/stdint.h"

#define CLINT_TIMER_OFFSET 0xbff8
#define MTIMECMP_BASE 0x4000

#define TIMER_FREQ 100000



namespace arch {
    extern volatile uint64_t *mtime;


    struct Timer {
        static void init(unsigned interval_ms = 1);
        static void reload();
        static void tick();

        static unsigned interval;
        static uint64_t timebase_frequency;
    };
}

#endif
