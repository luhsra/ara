
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "timers.h"
#include "semphr.h"
#include "event_groups.h"
#include "stream_buffer.h"
#include "message_buffer.h"

#include <stdint.h>


int main( void ){
	int a = 0;
	for(int i; i < 10; ++i){
		a = a + 1;
	};
	return 0;
}
