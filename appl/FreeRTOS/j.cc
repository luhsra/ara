
#include "source/include/FreeRTOS.h"
#include "source/include/task.h"
#include "source/include/queue.h"
#include "source/include/timers.h"
#include "source/include/semphr.h"
#include <stdint.h>


unsigned int ulCallCount = 0;
/* The periods assigned to the one-shot and auto-reload timers are 3.333 second and half a
second respectively. */
#define mainONE_SHOT_TIMER_PERIOD pdMS_TO_TICKS( 333 )
#define mainAUTO_RELOAD_TIMER_PERIOD pdMS_TO_TICKS( 500 )

static void prvOneShotTimerCallback( TimerHandle_t xTimer ){
	TickType_t xTimeNow;
	/* Obtain the current tick count. */
	xTimeNow = xTaskGetTickCount();
	/* Output a string to show the time at which the callback was executed. */
	
	/* File scope variable. */
	ulCallCount++;
}

static void prvAutoReloadTimerCallback( TimerHandle_t xTimer ){
	TickType_t xTimeNow;
	/* Obtain the current tick count. */
	xTimeNow = xTaskGetTickCount();
	/* Output a string to show the time at which the callback was executed. */
	
	ulCallCount++;
}



int main( void ){
		
	TimerHandle_t xAutoReloadTimer, xOneShotTimer;
	BaseType_t xTimer1Started, xTimer2Started;
	/* Create the one shot timer, storing the handle to the created timer in xOneShotTimer. */
	xOneShotTimer = xTimerCreate("OneShot",mainONE_SHOT_TIMER_PERIOD,pdFALSE,0,prvOneShotTimerCallback);
	/* Create the auto-reload timer, storing the handle to the created timer in xAutoReloadTimer. */
	xAutoReloadTimer = xTimerCreate("AutoReload",mainAUTO_RELOAD_TIMER_PERIOD,pdTRUE,0,prvAutoReloadTimerCallback);
	/* Check the software timers were created. */
	if( ( xOneShotTimer != NULL ) && ( xAutoReloadTimer != NULL ) ){
	/* Start the software timers, using a block time of 0 (no block time). The scheduler has
	not been started yet so any block time specified here would be ignored anyway. */
	xTimer1Started = xTimerStart( xOneShotTimer, 0 );
	xTimer2Started = xTimerStart( xAutoReloadTimer, 0 );
	/* The implementation of xTimerStart() uses the timer command queue, and xTimerStart()
	will fail if the timer command queue gets full. The timer service task does not get
	created until the scheduler is started, so all commands sent to the command queue will
	stay in the queue until after the scheduler has been started. Check both calls to
	xTimerStart() passed. */
	if( ( xTimer1Started == pdPASS ) && ( xTimer2Started == pdPASS ) ){
		/* Start the scheduler. */
		vTaskStartScheduler();
	}
	}
	/* As always, this line should not be reached. */
	for( ;; );
}
