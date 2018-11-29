
#include "source/include/FreeRTOS.h"
#include "source/include/task.h"
#include "source/include/queue.h"
#include "source/include/timers.h"
#include "source/include/semphr.h"
#include "source/include/event_groups.h"
#include "source/include/stream_buffer.h"
#include "source/include/message_buffer.h"

#include <stdint.h>


int main( void ){
	int a = 0;
	for(int i; i < 10; ++i){
		a = a + 1;
	};
	return 0;
}
