#include "FreeRTOS.h"
#include "semphr.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void task1(void*) { }

static xSemaphoreHandle mutex;
static xSemaphoreHandle mutex3;
static xSemaphoreHandle mutex4;
static xSemaphoreHandle mutex5;
static xTaskHandle t;

struct SemStruct {
	xSemaphoreHandle m1;
	xSemaphoreHandle m2;
};

static SemStruct mutexes;

int task_data = 746;
int global_value = 0;

void do_stuff(int a) {
	vTaskStepTick(a);
}

class Embed {
  private:
	int hidden = 5;

  public:
	void update(int a) { hidden = a; }
	void call() { vTaskStepTick(hidden); }
};

class Guard {
  private:
	int hidden;

  public:
	Guard(int hidden) : hidden(hidden) {}
	~Guard() { do_stuff(hidden); }
};

class Guard2 {
  private:
	SemaphoreHandle_t mutex;

  public:
	Guard2(SemaphoreHandle_t mtx) {
		mutex = mtx;
		xSemaphoreTake(mutex, 10);
	}
	~Guard2() {
		xSemaphoreGive(mutex);
	}
};

class Wrapper {
  private:
	SemaphoreHandle_t mtx;

  public:
	Wrapper() {
		mtx = xSemaphoreCreateMutex();
	}
	int do_stuff(int a) {
		Guard2 g(mtx);
		return a + 20;
	}
};

void make_mutex(xSemaphoreHandle* mutex_p) {
	*mutex_p = xSemaphoreCreateRecursiveMutex();
}

int main() {
	int a = 1234;
	int b = 333;
	int c = 6;
	int d = 4465;
	Embed embed;
	embed.update(1);
	embed.update(34);
	embed.call();
	// embed.update(89);
	// embed.call();
	xTaskHandle t2 = xTaskCreateStatic(task1, "TaskStatic", 11114, NULL, 1, NULL, NULL);
	xTaskHandle t3 = xTaskCreateStatic(task1, "TaskStatic1", 12344, &task_data, 5, NULL, NULL);
	// used one time
	mutex = xSemaphoreCreateRecursiveMutex();
	if (!mutex) {
		return;
	}
	// not used anymore
	mutex3 = xSemaphoreCreateRecursiveMutex();
	// argument handle
	make_mutex(&mutex4);
	make_mutex(&mutex5);
	xTaskCreate(task1, "Task 1", 6667, NULL, c, NULL);
	xTaskCreate(task1, "Task 2", 8889, NULL, c, &t);
	xTaskCreate(task1, "Task 3", 9993, NULL, c, &t2);
	Guard guard(d);
	c++;
	int x = c;
	do_stuff(a);
	do_stuff(b);
	xSemaphoreTakeRecursive(mutex, 5);
	xSemaphoreTakeRecursive(mutex4, 80);
	xSemaphoreTakeRecursive(mutex5, 14);
	global_value = 10101;
	vTaskStepTick(global_value);

	mutexes.m1 = xSemaphoreCreateRecursiveMutex();
	mutexes.m2 = xSemaphoreCreateRecursiveMutex();
	xSemaphoreTake(mutexes.m1, 10);
	xSemaphoreTake(mutexes.m2, 10);

	Wrapper w;
	x = w.do_stuff(x);
	Wrapper w2;
	x += w2.do_stuff(x);
	return x;
}
