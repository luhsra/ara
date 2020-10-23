#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);
void vTask2(void* pvParameters);

int ptr_func1(int a, float b, int c) { return a + c; }

int ptr_func2(int a, float b, int c) { vTaskDelay(5); return a - c; }

typedef int (*PtrFunc)(int, float, int);
PtrFunc get_ptr_func();

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
		ptr_func2(a, 5.0, 3);
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

PtrFunc complex_get_ptr_func(int a) {
	if (a < 12) {
		return ptr_func1;
	} else {
		return ptr_func2;
	}
}

void recursive();

void chain() {
	recursive();
}

void recursive() {
	xTaskCreate(vTask1, "Recursive", 510, NULL, 1, NULL);
	chain();
	xTaskCreate(vTask1, "Recursive2", 510, NULL, 1, NULL);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 510, NULL, 1, NULL);
	xTaskCreate(vTask2, "Task 2", 100, NULL, 1, NULL);

	int e = do_stuff(23, 90);

	// this is optimized out and therefore unambiguous
	auto ptr = ptr_func1;
	ptr(23, 4.5, 20);

	// this is impossible to optimize out
	auto ptr2 = get_ptr_func();
	ptr2(23, 4.5, 20);

	// this can be solved
	auto ptr3 = complex_get_ptr_func(23);
	ptr3(23, 4.5, 20);

	recursive();

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
