#include "source/include/FreeRTOS.h"
#include "source/include/task.h"

#include <stdint.h>

#define mainDELAY_LOOP_COUNT (0xffffff)

void vPrintString(const char* string);
void vTask1(void* pvParameters);
void vTask2(void* pvParameters);

TaskHandle_t xTask2Handle = NULL;

volatile uint32_t ulIdleCycleCount = 0UL;

void vApplicationIdleHook(void) { ulIdleCycleCount++; }

void vTask1(void* pvParameters) {
	const TickType_t xDelay100ms = pdMS_TO_TICKS(100UL);

	for (;;) {
		vPrintString("Task 1 is running");
		xTaskCreate(vTask2, "Task 2", 1000, NULL, 2, &xTask2Handle);
		vTaskDelay(xDelay100ms);
	}
}

void vTask2(void* pvParameters) {
	vPrintString("Task 2 is running and about to delete itself");
	vTaskDelete(xTask2Handle);
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
	vTaskStartScheduler();
	for (;;)
		;
}
