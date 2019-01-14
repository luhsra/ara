

QueueHandle_t xCharPointerQueue;
/* The handle of the queue from which uint32_t values are received. */
QueueHandle_t xUint32
tQueue;
/* The handle of the binary semaphore. */
SemaphoreHandle_t xBinarySemaphore;
/* The queue set 
to which the two queues 
and the binary semaphore belong.
*/

/* Declare two variables of type QueueHandle_t.  Both queues are added to the
same 
queue set. */
static QueueHandle_t xQueue1 = NULL, xQueue2 = NULL;
/* Declare a variable of type QueueSetHandle_t.  This is the queue set to which
the 
two 
queues are added. */
static QueueSetHandle_t xQueueSet = NULL;


void vSenderTask1( void *pvParameters ){
    const TickType_t xBlockTime = pdMS_TO_TICKS( 100 );
    const char * const pcMessage = "Message from vSenderTask1";
    /* As per most tasks, this task is implemented within an infinite loop. */
    for( ;; )
    {
        /* Block for 100ms. */
        vTaskDelay( xBlockTime );
        /* Send this task's string to xQueue1. 
        It is not necessary to use a block 
        time, even though the queue can only hold one item.  This is because the 
        priority of the task that reads from the queue is higher than the priority of 
        this task; as soon as this task writes to the queue it will be pre
        -
        empted by 
        t
        he task that reads from the queue, so the queue will already be empty again 
        by the time the call to xQueueSend() returns.  The block time is set to 0. */
        xQueueSend( xQueue1, &pcMessage, 0 );
    }
}
/*
-----------------------------------------------------------
*/
void vSenderTask2( void *pvParameters ){
    const TickType_t xBlockTime = pdMS_TO_TICKS( 200 );
    const char * const pcMessage = "Message from vSenderTask2";
    /* As per most tasks, this t
    ask is implemented within an infinite loop. */
    for( ;; )
    {
        /* Block for 200ms. */
        vTaskDelay( xBlockTime );
        /* Se
        nd this task's string to xQueue2
        . 
        It is not necessary to use a block 
        time, even though the queue can 
        only hold one item.  This is because the 
        priority of the task that reads from the queue is higher than the priority of 
        this task; as soon as this task writes to the queue it will be pre
        -
        empted by 
        the task that reads from the queu
        e, so the queue will already be empty again 
        by the time the call to xQueueSend() returns.  The block time is set to 0. */
        xQueueSend( xQueue2, &pcMessage, 0 );
    }
}




void vAMoreRealisticReceiverTask( void *pvParameters )
{
    QueueSetMemberHandle_t xHandle;
    char *pcReceivedString;
    uint32_t ulRecievedValue;
    const TickType_t xDelay100ms = pdMS_TO_TICKS( 100 );
    for( ;; ){
        /* Block on the queue set 
        for a maximum of 100ms 
        to wait for one of t
        he members of 
        the set to contain data.
        */
        xHandle = xQueueSelectFromSet( xQueueSet,  xDelay100ms  );
        /* Test the value returned from xQueueSele
        ctFromSet()
        .  If the returned value is 
        NULL then the call to xQueueSelectFromSet() timed out.  If the returned value is not 
        NULL then the returned value will be the handle of one of the set
        ’
        s members.  The 
        QueueSetMemberHandle_t value 
        can be cast to either a QueueHandle_t or a 
        SemaphoreHandle_t.  Whether an explicit cast is required depends on the compiler. 
        */
        if( xHandle == NULL )
        {
        /* The call to xQueueSelectFromSet() timed out. */
        }
        else if( xHandle ==    ( QueueSetMemberHandle_t ) xCharPointerQueue ){
            /* 
            The call to 
            xQueueSelectFromSet
            () returned the handle of the queue that 
            receives character pointers.  
            Read from the queue.  
            The queue is known to contain 
            data
            ,
            so 
            a 
            block time 
            of 0
            is used.
            */
            xQueueReceive( xCharPointerQueue, &pcReceivedString, 0 );
            /* The received character pointer can be processed here... */
        }
        else if( xHandle ==   (QueueSetMemberHandle_t)   xUint 32  tQueue ) {
            /* 
            The call to 
            xQueueSelectFromSet
            () returned the handle of the queue that 
            receives uint32_t types.  
            Read from the queue.  
            The queue is known to contain 
            data, so a block time of 0 is used. */
            xQueueReceive(xUint    32     tQueue, &ulRecievedValue, 0 );
            /* The received value can be processed here... */
        }
        else if( xHandle ==      (     QueueSetMemberHandle_t      )    xBinarySemaphore )        {
            /* 
            The call to xQueueSelectFromSet() returned the handle of the binary 
            semaphore.  
            Take the semaphore now.  
            The semaphore is kn
            own to be available so a block
            time 
            of 0 is used.
            */
            xSemaphoreTake(  xBinarySemaphore, 0 );
            /* Whatever processing is necessary when the semaphore is taken can be 
            performed
            here... */
        }
    }
}


int main( void )
{
    /* Create the two queues, both of 
    which send character pointers. 
    The
    priority 
    of the receiving task is above the priority of the sending tasks
    ,
    so
    the queues 
    will never have more than one item in them at any one time
    */
    xQueue1 = xQueueCreate( 1, sizeof( char * ) );
    xQueue2 = xQueueCreate( 1, sizeof( char * ) );
    /* Create the queue set.  
    Two queues will be added to the set, each of which can 
    contain 1 item,
    so the 
    maximum number of 
    queue handles
    the queue set will ever 
    have to hold at one time is 
    2 (2 queues multiplied by 1 item per queue). */
    xQueueSet = xQueueCreateSet( 1 * 2 );
    /* Add the two queues to the set. */
    xQueueAddToSet( xQueue1, xQueueSet );
    xQueueAddToSet( xQueue2, xQueueSet );
    /* Create the tasks that send to the queues
    . */
    xTaskCreate( vSenderTask1, "Sender1", 1000, NULL, 1, NULL );
    xTaskCreate( vSenderTask2, "Sender2", 1000, NULL, 1, NULL );
    /* Create the 
    task that reads from the queue set to determine which of the two 
    queues contain data
    . */
    xTaskCreate( vReceiverTask, "Receiver", 1000, NULL, 2, NULL );
    /* Start the scheduler so the created tasks start executing. */
    vTaskStartScheduler();
    /* As normal, vTaskStartScheduler() should not return
    , so the following lines  Willnever execute. */
    for( ;; );
    return 0;
}
