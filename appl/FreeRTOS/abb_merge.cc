#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);
void vTask2(void* pvParameters);
void vTask3(void* pvParameters) {}
void vTask4(void* pvParameters) {}

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

int complicated(int a, int b) {
	int ret = a * b;
	for (int i = 0; i < a; ++i) {
		switch (b) {
			case 4:
				return 23;
			case 2:
				ret += a;
				break;
			case 8:
				ret += 5*a;
				break;
			case 3:
				goto end;
			case 9:
				xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
			default:
				continue;
		}
	}
	while (b-- > 0) {
		if (b == 3) {
			xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
			return 10;
		}
	}
end:
	ret += 2*b;
	return ret;
}

void recur1(int a);

void recur2(int a) {
	if (a != 3) {
		recur1(a-1);
		xTaskCreate(vTask4, "Task 4", 1000, NULL, 1, NULL);
	}
}

void recur1(int a) {
	if (a != 0) {
		recur2(a-1);
	}
}

void some_loops(int param) {
	int a = 0;
	int b = 0;
	for(int i = 0; i < param; ++i) {
		a += i * a;
	}
	xTaskCreate(vTask4, "Task 5", 1000, NULL, a, NULL);
	if (a > param) {
		b += 10 + a + param;
		for(int i = 0; i < b; ++i) {
			b += b;
		}
	} else {
		b += 2 + param;
	}
	xTaskCreate(vTask4, "Task 6", 1000, NULL, b, NULL);
}

int other_function(int a) {
	endless_loop();
	xTaskCreate(vTask3, "Task 3", 1000, NULL, 1, NULL);
	endless_loop2(false);
	return do_stuff(a, 6);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
	xTaskCreate(vTask2, "Task 2", 1000, NULL, 1, NULL);

	int e = do_stuff(23, 90);

	complicated(14, 90);

	some_loops(e);

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

		recur1(34);
	}
}
