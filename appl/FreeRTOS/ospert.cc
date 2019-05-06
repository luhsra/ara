#include "source/include/FreeRTOS.h"
#include "source/include/task.h"

struct BoundedBuffer {
	void put(int) {}
	int get() { return 0; }
};

int readSerial() { return 0; }
void handleSerial(int) { }

void handleADC(int) { }
int readADC() { return 0; }

BoundedBuffer bb;
TaskHandle_t t1 = NULL, t2 = NULL;

void task_1(void*) { // priority: 2
  int data;
  while(1) {
     ulTaskNotifyTake(pdTRUE, 0);
     while((data = bb.get()))
       handleSerial(data);
  }
}

void task_2(void*) { // priority: 1
  while (true)
    handleADC(readADC());
}

int main() {
  xTaskCreate(task_1, "Task 1", 1000, NULL, 2, &t1);
  xTaskCreate(task_2, "Task 2", 1000, NULL, 1, &t2);
  vTaskStartScheduler();
}

void isr_1() { // priority: $\infty$
  int data = readSerial();
  bb.put(data);
  BaseType_t x = pdFALSE;
  vTaskNotifyGiveFromISR(t1, &x);
}

