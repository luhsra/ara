#include "FreeRTOS.h"
#include "queue.h"
#include "semphr.h"
void do_preparations();
void do_critical();
void do_critical2();
void do_work();
int unknown_condition();
void uncertainTask(void *param);
void *uncertainArgument = (void *) (((int)uncertainTask) & ~(1<<31)); void argumentTask(void*);
QueueHandle_t mutex;

void useComputation(void *param);

void task1(void *param) {
  do_preparations();
  mutex = xSemaphoreCreateMutex();
  xTaskCreate(useComputation, "User", 100, NULL, 1, NULL);
  for(;;) {
    if (xQueueSemaphoreTake(mutex, portMAX_DELAY) == pdTRUE) {
      do_critical2();
      xSemaphoreGive(mutex);
    }
  }
  do_work();
}

void useComputation(void *param) {
  for (;;) {
    if (xQueueSemaphoreTake(mutex, portMAX_DELAY) == pdTRUE) {
      do_critical();
      xSemaphoreGive(mutex);
    }
  }
}

int main() {
  xTaskCreate(task1, "Task1", 100, NULL, 2, NULL);
  if (unknown_condition()) {
    xTaskCreate(uncertainTask, "uncertainTask", 120, NULL, 1, NULL);
  }
  xTaskCreate(argumentTask, "argumentTask", 110, uncertainArgument, 3, NULL);
  vTaskStartScheduler();
}


void uncertainTask(void *) {
  for(;;);
}

void argumentTask(void *) {
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

void do_preparations() {
  critical_data = (int)main + 12;
}

