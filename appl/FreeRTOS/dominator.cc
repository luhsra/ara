
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
