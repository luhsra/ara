#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <task.h>
#include <output.h>

volatile int i = 0;
void vTask2(void * param) {
  for (;;) {
	kout << 't';
	for (i = 0; i < 300000; ++i);
  }
}

volatile int j = 0;
void vTask1(void * param) {
  for (;;) {
	kout << 'T';
	for (j = 0; j < 300000; ++j);
  }
}

void InitBoard();

int main() {
  InitBoard();
  kout.init();

  kout << 'z' << endl;
  kout << "hello from main" << endl;
  xTaskCreate(vTask1, "zzz", 1000, NULL, 1, NULL);
  xTaskCreate(vTask2, "xxx", 1000, NULL, 1, NULL);
  vTaskStartScheduler();

}
