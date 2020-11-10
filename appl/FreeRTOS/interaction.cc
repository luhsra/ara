#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"
#include "semphr.h"

QueueHandle_t mutex;
void task2(void *param) {
  for (;;) {
    if (xSemaphoreTake(mutex, portMAX_DELAY) == pdTRUE) {
      xSemaphoreGive(mutex);
    }
  }
}
void task1(void *param) {
  mutex = xSemaphoreCreateMutex();
  xTaskCreate(task2, "User", 100, NULL, 1, NULL);
  for(;;) {
    if (xSemaphoreTake(mutex, portMAX_DELAY) == pdTRUE) {
      xSemaphoreGive(mutex);
    }
  }
}

void task3(void *param) {
  while(true) {}
}

int main() {
  xTaskCreate(task1, "Task1", 100, NULL, 2, NULL);
  xTaskCreate(task3, "Task3", 120, NULL, 1, NULL);
  vTaskStartScheduler();
}
