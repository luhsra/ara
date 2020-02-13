#include "FreeRTOS.h"
#include "task.h"

extern "C" void prvTaskExitError( void );
extern "C" void prvIdleTask( void * );


template <unsigned int stacksize>
struct InitializedStack_t {
       StackType_t zero[stacksize-5] = {0};
       uint32_t arguments = 0;
       void * returnAddr = (void*) prvTaskExitError;
       void * startFunc;
       uint32_t magic = 0x01000000UL;
       StackType_t zero2[1] = {0};

       explicit InitializedStack_t(void* start) : startFunc(start) {}
} __attribute__((packed));
