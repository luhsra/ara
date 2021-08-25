#include "time_markers.h"

#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <output.h>
#include <platform.h>
#include <queue.h>
#include <semphr.h>
#include <task.h>

TIME_MARKER(task2_go);
TIME_MARKER(task1_go);
TIME_MARKER(main_start);
TIME_MARKER(done_InitBoard);
TIME_MARKER(done_hello_print);
TIME_MARKER(done_tastCreate);

class GuardedSingleton {
  public:
	static GuardedSingleton& instance() { return _the_instance; }
	void putc(char c) {
		xSemaphoreTake(guard_mutex, portMAX_DELAY);
		kout << c;
		xSemaphoreGive(guard_mutex);
	}

  private:
	GuardedSingleton() { guard_mutex = xSemaphoreCreateMutex(); }
	GuardedSingleton(const GuardedSingleton& s) = delete;
	GuardedSingleton(const GuardedSingleton&& s) = delete;
	SemaphoreHandle_t guard_mutex;
	static GuardedSingleton _the_instance;
};
GuardedSingleton GuardedSingleton::_the_instance;

TaskHandle_t handle_zzz;

QueueHandle_t global_mutex;

volatile int i = 0;
void vTask2(void* param) {
	STORE_TIME_MARKER(task2_go);
	taskENTER_CRITICAL();
	print_startup_statistics();
	taskEXIT_CRITICAL();
	for (int i = 0; i < 3; ++i) {
		GuardedSingleton::instance().putc('t');
		taskYIELD();
	}
	for (;;) {
	};
}

volatile int j = 0;
void vTask1(void* param) {
	STORE_TIME_MARKER(task1_go);
	for (int i = 0; i < 3; ++i) {
		GuardedSingleton::instance().putc('T');
		taskYIELD();
	}
	for (j = 0; j < 300000; ++j)
		;
	taskENTER_CRITICAL();
	kout << endl;
	kout << "my_handle: " << xTaskGetCurrentTaskHandle() << endl;
	kout << "T1 handle: " << handle_zzz << endl;
	taskEXIT_CRITICAL();
	StopBoard();
}

int main() {
	STORE_TIME_MARKER(main_start);
	InitBoard();
	STORE_TIME_MARKER(done_InitBoard);
	kout.init();

	kout << 'z' << endl;
	kout << "hello from main" << endl;
	STORE_TIME_MARKER(done_hello_print);

	global_mutex = xSemaphoreCreateMutex();

	xTaskCreate(vTask1, "zzz", 1000, NULL, 1, &handle_zzz);
	xTaskCreate(vTask2, "xxx", 1000, NULL, 1, NULL);
	STORE_TIME_MARKER(done_tastCreate);

	vTaskStartScheduler();
}
