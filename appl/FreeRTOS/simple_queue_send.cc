#include <FreeRTOS.h>
#include <FreeRTOSConfig.h>
#include <task.h>
#include <queue.h>
#include <output.h>
#include "time_markers.h"
#include <platform.h>


TIME_MARKER(task2_go);
TIME_MARKER(task1_go);
TIME_MARKER(main_start);
TIME_MARKER(done_InitBoard);
TIME_MARKER(done_hello_print);
TIME_MARKER(done_tastCreate);
TIME_MARKER(done_queueCreate);

QueueHandle_t queue_handle_2;
QueueHandle_t queue_handle_3;

void vTask2(void * param) {
  STORE_TIME_MARKER(task2_go);
  for (;;) {
    char c;
    BaseType_t success = xQueueReceive(queue_handle_2, &c, 500);
    if (! success) {
      kout << "ERROR: queueReceive failed" << endl;
    }
    kout << (char) (c ^ 0x20); // Print with inverted cASE
  }
  for (;;) vTaskDelay(1000);
}

void vTask3(void * param) {
  STORE_TIME_MARKER(task2_go);
  for (;;) {
    char c;
    BaseType_t success = xQueueReceive(queue_handle_3, &c, 500);
    if (! success) {
      kout << "ERROR: queueReceive failed" << endl;
    }
    kout << (char) (c - 13); // print rot13
  }
  for (;;) vTaskDelay(1000);
}

void send_2();
void send_3();
void vTask1(void * param) {
  STORE_TIME_MARKER(task1_go);
  send_2();
  vTaskDelay(20);
  send_3();
  vTaskDelay(20);
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

  xTaskCreate(vTask1, "zzz", 100, NULL, 2, NULL);
  xTaskCreate(vTask2, "xxx", 100, NULL, 3, NULL);
  xTaskCreate(vTask3, "xxx", 100, NULL, 1, NULL);
  STORE_TIME_MARKER(done_tastCreate);

  queue_handle_2 = xQueueCreate(3, sizeof(char));
  if (queue_handle_2 == NULL) {
    kout << "ERROR: Queue1 creation failed" << endl;
  }
  queue_handle_3 = xQueueCreate(3, sizeof(char));
  if (queue_handle_3 == NULL) {
    kout << "ERROR: Queue3 creation failed" << endl;
  }
  STORE_TIME_MARKER(done_queueCreate);
  vTaskStartScheduler();

}


void send_2() {
  char small_t = 't';
  for (int n=0; n < 4; ++n) {
    for (int i = 0; i < 3; ++i) {
      xQueueSend(queue_handle_2, &small_t, 500);
      kout << small_t;
    }
    small_t++;
  }
}

void send_3() {
  char small_t = 't';
  for (int n=0; n < 4; ++n) {
    for (int i = 0; i < 3; ++i) {
      xQueueSend(queue_handle_3, &small_t, 500);
      kout << small_t;
    }
    small_t++;
  }
}
