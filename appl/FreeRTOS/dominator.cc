
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
	
	int a = 10;
	
	if(a == 10){
		
		a = a - 10;
		if(a > 2)a=10;
		else a = 3;
			
	}else{
		a = 100;
		
		a = 100 +11;
		if(a == 10)a = 0;
		else a = 100;
	}
	
	
	return 0;
}
