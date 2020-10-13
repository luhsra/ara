#include "FreeRTOS.h"
#include "task.h"

extern "C" void prvTaskExitError( void );
extern "C" void prvIdleTask( void * );


template <unsigned int stacksize>
struct InitializedStack_t {
  StackType_t zero[stacksize-5];
  void * arguments;
  void * returnAddr;
       void * startFunc;
  uint32_t magic;
  StackType_t zero2[1];

  InitializedStack_t(void* start, void* arguments) : arguments(arguments), startFunc(start), magic(0x01000000UL), returnAddr((void*) prvTaskExitError) {}
} __attribute__((packed));
