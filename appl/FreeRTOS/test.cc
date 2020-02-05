
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
	int i = 0;
	for(; i < 10;){
		a = a + 1;
		i++;
	};
	

	
	return 0;
}
