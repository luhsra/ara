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


#define SemaphoreHandle_t QueueHandle_t
#define xTaskCreate(name, fn, stack, prio) xTaskCreate((TaskFunction_t)fn, name, stack, NULL, prio, NULL)
#define xTaskCreateStatic(name, fn, ssize, prio, stack, tcb)\
  xTaskCreate(name, fn, ssize, prio)
/* xTaskCreateStatic((TaskFunction_t)fn, name, ssize, NULL, prio, stack, tcb) */
#define vStartScheduler() vTaskStartScheduler()
#define xCreateMutex() xSemaphoreCreateMutex()
void do_preparations();
void do_critical();
void do_critical2();
void do_work();
int unknown_condition();
void uncertainTask();
void *uncertainArgument = (void *) (((int)uncertainTask) & ~(1<<31));
void argumentTask();
void useComputation();

void t1_entry();
void t2_entry();
void t3_entry();
void t4_entry();
void t5_entry();
void library_init();
int dynPrio = ((int)t1_entry>>3)&3;
void printf(char *) {return;}



/// SICHTBAR ab hier

//startx1
StackType_t stack[1024];
StaticTask_t tcb;

int main() {
  printf("Starting system\n");
  xTaskCreate("task1", t1_entry, 512, 2);
  if (unknown_condition()) {
    xTaskCreate("task3", t3_entry, 128, 1);
  }
  library_init();
  xTaskCreateStatic("task4", t4_entry,
                    256, 2, stack, &tcb);
  vStartScheduler();
}
SemaphoreHandle_t mutex1;
void library_init() {
    mutex1 = xCreateMutex();
    return;
}
//endx1
//startx2
void t1_entry() {
  xTaskCreate("task2", t2_entry, 256, dynPrio);
  for(;;) { /* ... */ }
}

void t2_entry() { for (;;) { /* ... */  } }

void t3_entry() { for (;;) { /* ... */  } }

void t4_entry() {
    xTaskCreate("task5", t5_entry, 512, 2);
    for (;;) { /* ... */  }
}

MessageBufferHandle_t buffer1;
void t5_entry() {
    buffer1 = xMessageBufferCreate(12);
    for (;;) { /* ... */  }
}

//endx2


void uncertainTask() {
  for(;;);
}

void argumentTask() {
  for(;;);
}

int unknown_condition() {
  return (int)main * 37 & (1<<23);
}

volatile int critical_data;
void do_critical() {
  critical_data += (int)main+13;
}

void do_critical2() {
  critical_data -=  (int)main-13;

}

#ifdef __cplusplus
}
#endif
