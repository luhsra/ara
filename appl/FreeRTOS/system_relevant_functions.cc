#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

int ptr_func1(int a, float b, int c) { return a + c; }

int ptr_func2(int a, float b, int c) { vTaskDelay(5); return a - b; }

typedef int (*PtrFunc)(int, float, int);
PtrFunc get_ptr_func();

PtrFunc complex_get_ptr_func(int a) {
	if (a < 12) {
		return ptr_func1;
	} else {
		return ptr_func2;
	}
}

void call_ptr_func() {
	auto ptr2 = get_ptr_func();
	ptr2(23, 4.5, 20);
}

void system_relevant() {
	vTaskDelay(5);
}

void recursion2();

void recursion1() {
	recursion2();
}

void recursion2() {
	system_relevant();
	recursion1();
}

void indirect() {
	system_relevant();
}

int system_irrelevant(int a, int b) {
	return a + b;
}

void indirect2() {
	system_irrelevant(4, 3);
}


int main(void) {
	indirect();
	indirect2();

	call_ptr_func();

	auto ptr3 = complex_get_ptr_func(23);
	ptr3(23, 4.5, 20);

	recursion1();

	for (;;)
	return 0;
}
