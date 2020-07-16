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
TIME_MARKER(begin_taskCreate);
TIME_MARKER(done_taskCreate);

TaskHandle_t handle_zzz;

volatile int running_tasks = 0;
volatile int started_tasks = 0;
void vTask1(void * param) {
  running_tasks++;
  taskENTER_CRITICAL();
  kout << pcTaskGetName( NULL ) << endl;;
  taskEXIT_CRITICAL();
  for (;;) vTaskDelay(100);
}

static void start_10(void);
static void start_20(void);
static void start_30(void);
static void start_40(void);
static void start_50(void);
static void start_60(void);
static void start_70(void);

static void start_10(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_20(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_30(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_40(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_50(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_60(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}

static void start_70(void) {
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
  xTaskCreate(vTask1, "xxx" STRINGIFY(__LINE__), 50, NULL, 1, NULL); started_tasks++; STORE_INLINE_TIME_MARKER(START);
}


extern "C" void vApplicationIdleHook(void) {
  kout << "running: " << running_tasks << endl;
  StopBoard(0);
}



void setup_task(void * param) {
  STORE_TIME_MARKER(begin_taskCreate);
  start_10();
  start_20();
  start_30();
  // following tasks yield to heap overflow
  // start_40();
  // start_50();
  // start_60();
  kout << started_tasks << endl;
  STORE_TIME_MARKER(done_taskCreate);
  for (;;) vTaskDelay(10000);
}

int main() {
  STORE_TIME_MARKER(main_start);
  InitBoard();
  STORE_TIME_MARKER(done_InitBoard);
  kout.init();

  kout << 'z' << endl;
  kout << "hello from main" << endl;
  STORE_TIME_MARKER(done_hello_print);
  xTaskCreate(setup_task, "setup", 100, NULL, 2, NULL);

  vTaskStartScheduler();

}
