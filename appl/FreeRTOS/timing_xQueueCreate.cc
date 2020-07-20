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
TIME_MARKER(begin_queueCreate);
TIME_MARKER(done_queueCreate);

QueueHandle_t queue001;
QueueHandle_t queue002;
QueueHandle_t queue003;
QueueHandle_t queue004;
QueueHandle_t queue005;
QueueHandle_t queue006;
QueueHandle_t queue007;
QueueHandle_t queue008;
QueueHandle_t queue009;
QueueHandle_t queue010;
QueueHandle_t queue011;
QueueHandle_t queue012;
QueueHandle_t queue013;
QueueHandle_t queue014;
QueueHandle_t queue015;
QueueHandle_t queue016;
QueueHandle_t queue017;
QueueHandle_t queue018;
QueueHandle_t queue019;
QueueHandle_t queue020;
QueueHandle_t queue021;
QueueHandle_t queue022;
QueueHandle_t queue023;
QueueHandle_t queue024;
QueueHandle_t queue025;
QueueHandle_t queue026;
QueueHandle_t queue027;
QueueHandle_t queue028;
QueueHandle_t queue029;
QueueHandle_t queue030;
QueueHandle_t queue031;
QueueHandle_t queue032;
QueueHandle_t queue033;
QueueHandle_t queue034;
QueueHandle_t queue035;
QueueHandle_t queue036;
QueueHandle_t queue037;
QueueHandle_t queue038;
QueueHandle_t queue039;
QueueHandle_t queue040;
QueueHandle_t queue041;
QueueHandle_t queue042;
QueueHandle_t queue043;
QueueHandle_t queue044;
QueueHandle_t queue045;
QueueHandle_t queue046;
QueueHandle_t queue047;
QueueHandle_t queue048;
QueueHandle_t queue049;
QueueHandle_t queue050;
QueueHandle_t queue051;
QueueHandle_t queue052;
QueueHandle_t queue053;
QueueHandle_t queue054;
QueueHandle_t queue055;
QueueHandle_t queue056;
QueueHandle_t queue057;
QueueHandle_t queue058;
QueueHandle_t queue059;
QueueHandle_t queue060;
QueueHandle_t queue061;
QueueHandle_t queue062;
QueueHandle_t queue063;
QueueHandle_t queue064;
QueueHandle_t queue065;
QueueHandle_t queue066;
QueueHandle_t queue067;
QueueHandle_t queue068;
QueueHandle_t queue069;
QueueHandle_t queue070;
QueueHandle_t queue071;
QueueHandle_t queue072;
QueueHandle_t queue073;
QueueHandle_t queue074;
QueueHandle_t queue075;
QueueHandle_t queue076;
QueueHandle_t queue077;
QueueHandle_t queue078;
QueueHandle_t queue079;
QueueHandle_t queue080;
QueueHandle_t queue081;
QueueHandle_t queue082;
QueueHandle_t queue083;
QueueHandle_t queue084;
QueueHandle_t queue085;
QueueHandle_t queue086;
QueueHandle_t queue087;
QueueHandle_t queue088;
QueueHandle_t queue089;
QueueHandle_t queue090;
QueueHandle_t queue091;
QueueHandle_t queue092;
QueueHandle_t queue093;
QueueHandle_t queue094;
QueueHandle_t queue095;
QueueHandle_t queue096;
QueueHandle_t queue097;
QueueHandle_t queue098;
QueueHandle_t queue099;
QueueHandle_t queue100;



static void start_10(void) {
  queue001 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue002 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue003 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue004 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue005 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue006 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue007 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue008 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue009 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue010 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue011 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue012 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue013 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue014 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue015 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue016 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue017 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue018 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue019 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue020 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue021 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue022 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue023 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue024 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue025 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue026 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue027 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue028 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue029 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue030 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue031 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue032 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue033 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue034 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue035 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue036 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue037 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue038 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue039 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue040 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue041 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue042 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue043 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue044 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue045 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue046 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue047 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue048 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue049 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue050 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue051 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue052 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue053 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue054 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue055 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue056 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue057 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue058 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue059 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue060 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue061 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue062 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue063 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue064 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue065 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue066 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue067 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue068 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue069 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue070 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue071 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue072 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue073 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue074 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue075 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue076 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue077 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue078 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue079 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue080 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue081 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue082 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue083 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue084 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue085 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue086 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue087 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue088 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue089 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue090 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue091 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue092 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue093 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue094 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue095 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue096 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue097 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue098 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue099 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
  queue100 = xQueueCreate(4, sizeof(char)); STORE_INLINE_TIME_MARKER(QUEUE);
}


extern "C" void vApplicationIdleHook(void) {
  StopBoard(0);
}


int main() {
  STORE_TIME_MARKER(main_start);
  InitBoard();
  STORE_TIME_MARKER(done_InitBoard);
  kout.init();

  STORE_TIME_MARKER(done_hello_print);
  STORE_TIME_MARKER(begin_queueCreate);
  start_10();
  STORE_TIME_MARKER(done_queueCreate);

  vTaskStartScheduler();

}
