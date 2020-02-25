#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <task.h>
#include <output.h>

void vTask2(void * param) {
  for (int n=0; n < 4; ++n) {
    taskENTER_CRITICAL();
	kout << 't';
    taskEXIT_CRITICAL();
    vTaskDelay(2000);
  }
  for (;;) vTaskDelay(100);
}

void vTask1(void * param) {
  for (int n=0; n < 4; ++n) {
    taskENTER_CRITICAL();
	kout << 'T';
    taskEXIT_CRITICAL();
    vTaskDelay(2000);
  }
  for (;;) vTaskDelay(100);
}

void InitBoard();

int main() {
  InitBoard();
  kout.init();

  kout << 'z' << endl;
  kout << "hello from main" << endl;

  xTaskCreate(vTask1, "zzz", 100, NULL, 1, NULL);
  xTaskCreate(vTask2, "xxx", 100, NULL, 1, NULL);

  vTaskStartScheduler();

}
