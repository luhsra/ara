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

QueueHandle_t mutex3;

int unknown_condition();

int main() {
  mutex3 = xSemaphoreCreateMutex();
  if (unknown_condition()) {
    xSemaphoreTake(mutex3, 0);
  }
}

int unknown_condition() {
  return (int)main * 37 & (1<<23);
}


#ifdef __cplusplus
}
#endif
