#include "FreeRTOSConfig.h"
#define configSUPPORT_STATIC_ALLOCATION 1
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "message_buffer.h"
#ifdef __cplusplus
extern "C" {
#if 0
}
#endif
#endif


void t1_entry(void*) { for (;;) { /* ... */  } }

QueueHandle_t q1;
TaskHandle_t t1;

int main() {
  xTaskCreate(t1_entry, "task1", 512, &t1, 2, NULL);
  q1 = xQueueCreate( 1, sizeof( char * ) );
}

void isr1() {
	vTaskNotifyGiveFromISR(t1, NULL);
}

void some_function() {
	vTaskNotifyGiveFromISR(t1, NULL);
}

void isr2() {
	some_function();
}

void some_other_function() {
	char c = 'b';
	xQueueSendFromISR(q1, &c, NULL);
}

void isr3() {
	some_function();
	some_other_function();
}


#ifdef __cplusplus
}
#endif
