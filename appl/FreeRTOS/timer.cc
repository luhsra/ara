 /* FreeRTOS.org includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"
#include "timers.h"
#include <stdint.h>
 
 /* An array to hold handles to the created timers. */
 TimerHandle_t Timer;

 /* Define a callback function that will be used by multiple timer
 instances.  The callback function does nothing but count the number
 of times the associated timer expires, and stop the timer once the
 timer has expired 10 times.  The count is saved as the ID of the
 timer. */
 void vTimerCallback( TimerHandle_t Timer )
 {
 const uint32_t ulMaxExpiryCountBeforeStopping = 10;
 uint32_t ulCount;

    /* The number of times this timer has expired is saved as the
    timer's ID.  Obtain the count. */
    ulCount = ( uint32_t ) pvTimerGetTimerID( Timer );

    /* Increment the count, then test to see if the timer has expired
    ulMaxExpiryCountBeforeStopping yet. */
    ulCount++;

    /* If the timer has expired 10 times then stop it from running. */
    if( ulCount >= ulMaxExpiryCountBeforeStopping )
    {
        /* Do not use a block time if calling a timer API function
        from a timer callback function, as doing so could cause a
        deadlock! */
        xTimerStop( Timer, 0 );
    }
    else
    {
       /* Store the incremented count back into the timer's ID field
       so it can be read back again the next time this software timer
       expires. */
       vTimerSetTimerID( Timer, ( void * ) ulCount );
    }
 }

 int main( void )
 {
 long x = 10;

     /* Create then start some timers.  Starting the timers before
     the RTOS scheduler has been started means the timers will start
     running immediately that the RTOS scheduler starts. */
   
         Timer = xTimerCreate
            ( /* Just a text name, not used by the RTOS
                kernel. */
                "TEST",
                /* The timer period in ticks, must be
                greater than 0. */
                 100,
                /* The timers will auto-reload themselves
                when they expire. */
                pdTRUE,
                /* The ID is used to store a count of the
                number of times the timer has expired, which
                is initialised to 0. */
                ( void * ) 0,
                /* Each timer calls the same callback when
                it expires. */
                vTimerCallback
            );

         if(Timer == NULL )
         {
             /* The timer was not created. */
         }
         else
         {
             /* Start the timer.  No block time is specified, and
             even if one was it would be ignored because the RTOS
             scheduler has not yet been started. */
             if( xTimerStart( Timer, 0 ) != pdPASS )
             {
                 /* The timer could not be set into the Active
                 state. */
             }
         }
     

     /* ...
     Create tasks here.
     ... */

     /* Starting the RTOS scheduler will start the timers running
     as they have already been set into the active state. */
     vTaskStartScheduler();

     /* Should not reach here. */
     for( ;; );
 }
