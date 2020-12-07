#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <task.h>
#include <output.h>
#include "time_markers.h"
#include <platform.h>
#include <queue.h>
#include <semphr.h>

TIME_MARKER(task2_go);
TIME_MARKER(task1_go);
TIME_MARKER(main_start);
TIME_MARKER(done_InitBoard);
TIME_MARKER(done_hello_print);
TIME_MARKER(done_taskCreate);

TaskHandle_t handle_zzz;
TaskHandle_t handle_xxx;
TaskHandle_t t2_handle;

QueueHandle_t mutex;

volatile int i = 0;
void vTask2(void * param) {
    STORE_TIME_MARKER(task2_go);
    for (int i = 0; i < 3; ++i) {
        kout << 'b';
        taskYIELD();
    }
    t2_handle = xTaskGetCurrentTaskHandle();
    vTaskDelay(1000);
    StopBoard(1);
    for (;;){};
}

volatile int j = 0;
void vTask1(void * param) {
    STORE_TIME_MARKER(task1_go);
    for (int i =0; i < 3; ++i) {
        kout << 'a';
        taskYIELD();
    }
    xTaskCreate(vTask2, "xxx", 100, NULL, 2, &handle_xxx);
    for (int i =0; i < 3; ++i) {
        kout << 'c';
        taskYIELD();
    }
    taskENTER_CRITICAL();
    kout << endl;
    kout << "t1 my_handle: " << xTaskGetCurrentTaskHandle() << endl;
    kout << "T1 handle: " << handle_zzz << endl;
    taskEXIT_CRITICAL();
    taskENTER_CRITICAL();
    kout << endl;
    kout << "t2 my_handle: " << t2_handle << endl;
    kout << "T2 handle: " << handle_xxx << endl;
    taskEXIT_CRITICAL();
    StopBoard(0);
}


int main() {
    STORE_TIME_MARKER(main_start);
    InitBoard();
    STORE_TIME_MARKER(done_InitBoard);
    kout.init();

    kout << 'z' << endl;
    kout << "hello from main" << endl;
    STORE_TIME_MARKER(done_hello_print);

    mutex = xSemaphoreCreateMutex();

    xTaskCreate(vTask1, "zzz", 1000, NULL, 1, &handle_zzz);
    STORE_TIME_MARKER(done_taskCreate);

    vTaskStartScheduler();

}
