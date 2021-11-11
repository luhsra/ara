#include "FreeRTOS.h"
#include "semphr.h"
#include "FreeRTOSConfig.h"
#include "task.h"

struct TaskStruct {
    TaskHandle_t task1;
    TaskHandle_t task2;
};

struct TaskStruct task_struct;

void task1(void*) { }
void task2(void*) { }

int main() {
	xTaskCreate(task1, "Task 1", 0, 0, 0, &task_struct.task1);
	xTaskCreate(task2, "Task 2", 0, 0, 0, &task_struct.task2);
	vTaskDelete(task_struct.task1);
	vTaskDelete(task_struct.task2);
}
