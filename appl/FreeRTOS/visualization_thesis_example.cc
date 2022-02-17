#include "FreeRTOSConfig.h"
#define configSUPPORT_STATIC_ALLOCATION 1
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "message_buffer.h"
#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif

#define xTaskCreate(name, fn, stack, prio) xTaskCreate((TaskFunction_t)fn, name, stack, NULL, prio, NULL)

void t1_entry();
void t2_entry();
void foo();

/// SICHTBAR ab hier

//startx1

int main() {
  foo();
  xTaskCreate("Main Task", t1_entry, 512, 2);
}
//endx1
//startx2

void foo() {
  xTaskCreate("Foo Task", t2_entry, 256, 3);
}

void t1_entry() { for (;;) { /* ... */  } }

void t2_entry() { for (;;) { /* ... */  } }

//endx2


#ifdef __cplusplus
}
#endif
