#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);
void vTask2(void* pvParameters);

int do_stuff(int a, int b) {
	if (a == 5) {
		return 34;
	}
	if (a == b) {
		return 42;
	}

	for (unsigned i = a; i < b || i < 1000; ++i) {
		if (i % 4 == a) {
			return 98;
		}
		if (i % 5 == a) {
			break;
		}
	}
	return 0;
}

int other_function(int a) {
	return do_stuff(a, 6);
}

void syscall_calling_func() {
	xTaskCreate(vTask1, "Task 3", 1000, NULL, 1, NULL);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
	xTaskCreate(vTask2, "Task 2", 1000, NULL, 1, NULL);

	syscall_calling_func();
	int e = do_stuff(23, 90);

	vTaskStartScheduler();

	for (;;)
	return 0;
}

void vTask1(void* pvParameters) {
	volatile long ul;
	for (;;) {
		int c = do_stuff(12, 76);

		/* Delay for a period. */
		for (ul = 0; ul < c; ul++) {
		}
	}
}

void vTask2(void* pvParameters) {
	volatile long ul;
	syscall_calling_func();
	for (;;) {
		int b = other_function(23);
		/* Delay for a period. */
		for (ul = 0; ul < b; ul++) {
		}
	}
}
