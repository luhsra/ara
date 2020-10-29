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


void do_critical();
void do_critical2();
void do_work();
int unknown_condition();
int unknown_condition2();
void uncertainTask();
void *uncertainArgument = (void *) (((int)uncertainTask) & ~(1<<31));
void useComputation();

void t1_entry(void*);
void t2_entry(void*);
void t3_entry(void*);
void t4_entry(void*);
void t5_entry(void*);

void library_init();

int dynPrio = ((int)t1_entry>>3)&3;

StackType_t stack[1024];
StaticTask_t tcb;

void t6_entry(void*) { for (;;) { /* ... */  } }

void o_func();

void create_in_recursion() {
  xTaskCreate(t6_entry, "RecursiveTask", 512, NULL, 2, NULL);
  o_func();
}

void o_func() {
  create_in_recursion();
}

QueueHandle_t mutex2, mutex3, mutex4, mutex5;

void func_create_mutex() {
  mutex3 = xSemaphoreCreateMutex();
  if (unknown_condition()) {
    mutex5 = xSemaphoreCreateMutex();
  }
}

void after_assert() {
  if (unknown_condition()) {
    // fail
    while(1) {}
  }
  func_create_mutex();
  mutex2 = xSemaphoreCreateMutex();
  if (unknown_condition2()) {
    mutex4 = xSemaphoreCreateMutex();
  }
}

int main() {
  xTaskCreate(t1_entry, "task1", 512, NULL, 2, NULL);
  if (unknown_condition()) {
    xTaskCreate(t3_entry, "task3", 128, NULL, 1, NULL);
  }
  library_init();
  xTaskCreateStatic(t4_entry, "task4", 256, NULL, 2, stack, &tcb);
  create_in_recursion();
  after_assert();
  vTaskStartScheduler();
}

QueueHandle_t mutex1;
void library_init() {
    mutex1 = xSemaphoreCreateMutex();
    return;
}

void t1_entry(void*) {
  xTaskCreate(t2_entry, "task2", 256, NULL, dynPrio, NULL);
  for(;;) { /* ... */ }
}

void t2_entry(void*) { for (;;) { /* ... */  } }

void t3_entry(void*) { for (;;) { /* ... */  } }

void t4_entry(void*) {
  xTaskCreate(t5_entry, "task5", 512, NULL, 2, NULL);
  for (;;) { /* ... */  }
}

MessageBufferHandle_t buffer1;
void t5_entry(void*) {
  buffer1 = xMessageBufferCreate(12);
  for (;;) { /* ... */  }
}

void uncertainTask() {
  for(;;);
}

int unknown_condition() {
  return (int)main * 37 & (1<<23);
}

int unknown_condition2() {
  return (int)main * 35 & (1<<21);
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
