#ifndef __ALARM3_COMMON_H__
#define __ALARM3_COMMON_H__

#define WAIT_FOR_IRQ_MAX 300000000

volatile bool stop = true;

#define WAIT_FOR_IRQ() do{ stop = false; \
	for (volatile unsigned long long counter = 0;			\
		 stop == false && counter < WAIT_FOR_IRQ_MAX; \
		 counter++) {                                                   \
    }                                                                   \
	} while(0);

#endif
