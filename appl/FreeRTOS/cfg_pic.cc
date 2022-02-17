#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);
void vTask2(void* pvParameters);
void vTask3(void* pvParameters) {}
void vTask4(void* pvParameters) {}

int do_stuff(int a, int b) {
	xTaskCreate(vTask2, "Task 2", a, NULL, b, NULL);
}


int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);

	int e = do_stuff(23, 90);

	return e;
}
