#include "source/include/FreeRTOS.h"
#include "source/include/task.h"

#include <stdint.h>

#define mainDELAY_LOOP_COUNT (0xffffff)

void vPrintString(const char* string);

TaskHandle_t xTask2Handle = NULL;
TaskHandle_t xTask1Handle = NULL;

volatile uint32_t ulIdleCycleCount = 0UL;

void vTask1(void* pvParameters) {
	UBaseType_t uxPriority;
	uxPriority = uxTaskPriorityGet(NULL);
	for (;;) {
		xTaskCreate(vTask1, "Task 1", 1000, xTask2Handle, 2, &xTask2Handle);
	}
}

int main(void) {
	xTaskCreate(vTask1, "Task 1", 1000, xTask2Handle, 2, &xTask2Handle);

	vTaskStartScheduler();
	for (;;)
		;
}
