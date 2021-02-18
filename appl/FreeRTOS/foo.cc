#include "FreeRTOS.h"
#include "FreeRTOSConfig.h"
#include "task.h"

void vTask1(void* pvParameters);

int main(void) {
	xTaskCreate(vTask1, "Task 1", 510, NULL, 1, NULL);

	vTaskStartScheduler();

	for (;;);
	return 0;
}

void vTask1(void* pvParameters) {
	for (;;) { }
}
