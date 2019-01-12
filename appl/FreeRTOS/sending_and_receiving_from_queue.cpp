static void vIntegerGenerator( void *pvParameters ){
    TickType_t
    xLastExecutionTime;
    uint32_t
    ulValueToSend = 0;
    int i;
    /* Initialize the variable used by the call to vTaskDelayUntil(). */
    xLastExecutionTime = xTaskGetTickCount();
    for( ;; )
    {
        /* This is
        a periodic task.  Block until it is time to run again.
        The task 
        will execute every 200ms. */
        vTaskDelayUntil( &xLastExecutionTime,    pdMS_TO_TICKS( 200 ) );
        /* Send five numbers to the queue, each value one higher than the previous 
        value.  The numbers are read from the queue by the interrupt service routine.  
        The interrupt service routine always empties the queue, so this task is 
        guaranteed to be able to write all five values without needing to specify a 
        block time. */
        for( i = 0; i < 5; i++ )
        {
            xQueueSendToBack( xIntegerQueue, &ulValueToSend, 0 );
            ulValueToSend++;
        }
        /* Generate the interrupt so the interrupt service routine can read the
        values from the queue. The syntax used to generate a software interrupt is 
        dependent on the FreeRTOS port being used.  The syntax used below can only be 
        used with the FreeRTOS Windows port, in which such interrupts are only 
        simulated.*/
        vPrintString( "TEST");
        vPortGenerateSimulatedInterrupt( mainINTERRUPT_NUMBER );
        vPrintString( "TEST");
    }
}



static uint32_t ulExampleInterruptHandler( void ) {
    BaseType_t xHigherPriorityTaskWoken;
    uint32_t ulReceivedNumber;
    /* The strings are declared static c
    onst to ensure they are not allocated on the
    interrupt service routine's stack, and 
    so 
    exist even when the interrupt service
    routine is not executing. */

    static const char *pcStrings[] =
    {   "String 0  \  r  \ n",
        "String 1  \  r  \ n",
        "String 2  \  r  \ n",
        "String 3  \  r  \ n",
        "String 4  \  r  \ n",

    };
    /* As always, xHigherPriorityTaskWoken is initialized to pdFALSE to be able to 
    detect it getting set to pdTRUE inside an
    interrupt safe API function. Note that 
    as an interrupt safe API function can only set xHigherPriorityTaskWoken to 
    pdTRUE, it is safe to use the same xHigherPriorityTaskWoken variable in both 
    the call to xQueueReceiveFromISR() and the call to xQueueSendToBackFromISR(). */

    xHigherPriorityTaskWoken = pdFALSE;

    /* Read from the queue until the queue is empty. */
    while( xQueueReceiveFromISR( xIntegerQueue, &ulReceivedNumber, xHigherPriorityTaskWoken ) != errQUEUE_EMPTY )
    {
        /* Truncate the received value to the last two bits (values 0 to 3
        inclusive, then use the truncated value as an index into the pcStrings[]
        array to select a string (char *) to send on the other queue. */
        ulReceivedNumber &= 0x03;
        xQueueSendToBackFromISR( xStringQueue, &pcStrings[ ulReceivedNumber ], &xHigherPriorityTaskWoken );
    }
    /* 
    If    receiving  from xIntegerQueue caus
    ed a task to leave the Blocked state, and 
    if the priority of the task that left the Blocked state is higher than the 
    pr  iority of the task in the Running state, then xHigherPriorityTaskWoken will 
    have been set to pdTRUE inside xQueueReceiveFromISR().    If  sending to xStringQueue caused a task to leave the Blocked state, and if the 
    priority of the task that left the Blocked state is higher than the priority of 
    the task in the Running state, then xHigherPriorityTaskWoken will have been set
    to pdTRUE inside xQueue Send ToBack FromISR(). xHigherPriorityTaskWoken is used as
    the parameter to portYIELD_FROM_ISR(). If     xHigherPriorityTaskWoken equals pdTRUE 
    then calling portYIELD_FROM_ISR()will request a context switch.  If xHigherPriorityTaskWoken
    is still pdFALSE then calling portYIELD_FROM_ISR() will have no effect.The implementation
    of portYIEL D_FROM_ISR() used by the Windows port includes a  return statement, which is
    why this function does not explicitly return a value. */

    portYIELD_FROM_ISR( xHigherPriorityTaskWoken );
}



static void vStringPrinter( void *pvParameters ){
    char *pcString;
    for( ;; )
    {
        /* Block on the queue to wait for data to arrive. */
        xQueueReceive( xStringQueue, &pcString, portMAX_DELAY );
        /* Print out the string received. */
        vPrintString( pcString );
    }
}


int main( void ){
    /* Before a queue can be used it must first be created.  Create both queues used by this example. One queue can hold variables of type  uint32_t
    , the other queue  can hold variables of type char*.  Both queues can hold a maximum of 10 items.  A  real application should check the return 
    values to ensure the queues have been successfully created. */

    xIntegerQueue = xQueueCreate( 10, sizeof( uint32_t ) );

    xStringQueue = xQueueCreate( 10, sizeof( char * ) );

    /* Create the task that uses a queue to pass integers to the interrupt service
    routine.  The task is created at priority 1. */

    xTaskCreate( vIntegerGenerator, "IntGen", 1000, NULL,  1, NULL );

    /* Create the task that prints out the strings sent to it from the interrupt
    service routine.  This task is created at the higher priority of 2. */

    xTaskCreate( vStringPrinter, "String", 1000, NULL, 2, NULL );
    /* Install the h andler for the software interrupt.  The syntax necessary
    to do   this is dependent on the FreeRTOS port being used.  The syntax
    shown here can  only be used with the FreeRTOS Windows port, where such interrupts are only 
    simulated. */

    vPortSetInterruptHandler( mainINTERRUPT_NUMBER, ulExampleInterruptHandler );
    /* Start the scheduler so the created tasks start executing. */

    vTaskStartScheduler();

    /* If all is well then main() will never reach here as the scheduler will now be 
    running the tasks.  If main() does reach here then it is likely that there was 
    insufficient heap memory available for the idle task to be created. 
    Chapter 2   provides more information o  heap  memory management. */
    for( ;; );
}
