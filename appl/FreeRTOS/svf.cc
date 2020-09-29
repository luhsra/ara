#include "FreeRTOS.h"
#include "semphr.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void task1(void*) { }

static xSemaphoreHandle mutex;
static xSemaphoreHandle mutex2;
static xSemaphoreHandle mutex3;
static xTaskHandle t;

void do_stuff(int a) {
	vTaskStepTick(a);
}

class Guard {
  private:
	int hidden;

  public:
	Guard(int hidden) : hidden(hidden) {}
	~Guard() { do_stuff(hidden); }
};

int main() {
	int a = 1234;
	int b = 333;
	int c = 6;
	int d = 4465;
	xTaskHandle t2 = xTaskCreateStatic(task1, "TaskStatic", 11114, NULL, 1, NULL, NULL);
	// used one time
	mutex = xSemaphoreCreateRecursiveMutex();
	// used multiple times
	mutex2 = xSemaphoreCreateRecursiveMutex();
	// not used anymore
	mutex3 = xSemaphoreCreateRecursiveMutex();
	xTaskCreate(task1, "Task 1", 6667, NULL, c, NULL);
	xTaskCreate(task1, "Task 2", 8889, NULL, c, &t);
	xTaskCreate(task1, "Task 3", 9993, NULL, c, &t2);
	Guard guard(d);
	c++;
	int x = c;
	do_stuff(a);
	do_stuff(b);
	xSemaphoreTakeRecursive(mutex, 5);
	xSemaphoreTakeRecursive(mutex2, 5);
	xSemaphoreTakeRecursive(mutex2, 5);
	return x;
}
