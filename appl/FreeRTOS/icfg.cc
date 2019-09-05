#include "source/include/FreeRTOS.h"
#include "source/include/FreeRTOSConfig.h"
#include "source/include/task.h"

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

int endless_loop() {
	while (true) {
	}
}

int endless_loop2(bool a) {
	if (a) {
		return 5;
	}
	while (true) {
	}
}

int other_function(int a) {
	endless_loop();
	endless_loop2(false);
	return do_stuff(a, 6);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
	xTaskCreate(vTask2, "Task 2", 1000, NULL, 1, NULL);

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
	for (;;) {
		int b = other_function(23);
		/* Delay for a period. */
		for (ul = 0; ul < b; ul++) {
		}
	}
}
