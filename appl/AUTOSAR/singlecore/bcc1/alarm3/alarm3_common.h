#ifndef __ALARM3_COMMON_H__
#define __ALARM3_COMMON_H__

#ifdef CONFIG_ARCH_POSIX
#define WAIT_FOR_IRQ_MAX 200000000
#else
#define WAIT_FOR_IRQ_MAX 20000000
#endif

volatile bool stop;

#define WAIT_FOR_IRQ() do{ stop = false; \
	for (volatile unsigned long long counter = 0;			\
		 stop == false && counter < WAIT_FOR_IRQ_MAX; \
		 counter++) {                                                   \
    }                                                                   \
	} while(0);

#endif
