#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <task.h>
#include <output.h>
#include "time_markers.h"
#include <platform.h>


TIME_MARKER(task2_go);
TIME_MARKER(task1_go);
TIME_MARKER(main_start);
TIME_MARKER(done_InitBoard);
TIME_MARKER(done_hello_print);
TIME_MARKER(done_tastCreate);

void vTask2(void * param) {
  STORE_TIME_MARKER(task2_go);
  for (int n=0; n < 4; ++n) {
    taskENTER_CRITICAL();
	kout << 't';
    taskEXIT_CRITICAL();
    vTaskDelay(2000);
  }
  for (;;) vTaskDelay(100);
}

void vTask1(void * param) {
  STORE_TIME_MARKER(task1_go);
  for (int n=0; n < 4; ++n) {
    taskENTER_CRITICAL();
	kout << 'T';
    taskEXIT_CRITICAL();
    vTaskDelay(2000);
  }
  for (int i=0; i < 3; ++i)
    vTaskDelay(100);
  StopBoard();
}

int main() {
  STORE_TIME_MARKER(main_start);
  InitBoard();
  STORE_TIME_MARKER(done_InitBoard);
  kout.init();

  kout << 'z' << endl;
  kout << "hello from main" << endl;
  STORE_TIME_MARKER(done_hello_print);

  xTaskCreate(vTask1, "zzz", 100, NULL, 1, NULL);
  xTaskCreate(vTask2, "xxx", 100, NULL, 1, NULL);
  STORE_TIME_MARKER(done_tastCreate);

  vTaskStartScheduler();

}
