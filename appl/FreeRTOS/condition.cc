#include "FreeRTOS.h"
#include "semphr.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void task1(void*) { }
bool get();

void create() {
	xTaskCreate(task1, "FOO", 0, NULL, 0, NULL);
}

void condition() {
	if (get()) {
		create();
	}
}

void do_while() {
	do {
		create();
	} while (get());
}

void no_while() {
	while (get()) {
		create();
	}
}

void endless_loop1() {
	create();
	while(1) {
		create();
	}
}

void endless_loop2() {
	create();
	while(1) {
		if (get()) {
			return;
		}
		create();
	}
}

int main() {
	condition();
	no_while();
	do_while();
	endless_loop2();
	endless_loop1();
	create();
}
