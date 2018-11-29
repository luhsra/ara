#include "source/os/os.h"
#include "source/test/test.h"


DeclareResource(SPIBusResource);

DeclareAlarm(SamplingAlarm);

DeclareEvent(CopterControlReceiveEvent);



DeclareTask(InitTask);
DeclareTask(SignalGatherInitiateTask);

ISR2(isr_button_start){
	int a = 0;
	int b = 0;
	
}

int main(void) {
	Schedule();
	return 0;
}		

static unsigned int time_counter = 0;

static int spi_reply_idx;


// autostarted by dOSEK!
TASK(InitTask) {
   
	//test_trace(INIT_TASK);

	// We set up a period alarm for initate the sampling task. This
    // Task runs every 3 ms. This activates the SignalGatherInitateTask.
    SetRelAlarm(SamplingAlarm, 100, 3);
	
	unsigned short tmp = 100;
	GetAlarm(SamplingAlarm,&tmp);
    ActivateTask(InitTask);
	ClearEvent(CopterControlReceiveEvent);
    TerminateTask();
}


TASK(SignalGatherInitiateTask) {
    time_counter++;
	test_trace('2');

    // Our benchmark should do exactly  actuate rounds.
    if (time_counter >  3 * 3 + 1) {
		Machine::disable_interrupts();
        CancelAlarm(SamplingAlarm);
        //CancelAlarm(ActuateAlarm);
        //CancelAlarm(CopterControlWatchdogAlarm);
        //test_trace(SHUTDOWN);
		test_trace('3');
		ShutdownMachine();
    }

    // Activate the processing tasks, they clear their event masks
    // immediatly, and then go to sleep.
    ActivateTask(InitTask);
   
    // First of all we would sample our analog sensors, which is done
    // imediately. Therefore the event can be set.
    SetEvent(InitTask, CopterControlReceiveEvent);

    // Before we send our data to "SPI", we set up a timeout alarm to
    // activate the signal processing after an exact time.
    CancelAlarm(SamplingAlarm); // after 2 ms
    SetRelAlarm(SamplingAlarm, 2, 0); // after 2 ms

    {
        GetResource(SPIBusResource);

		spi_reply_idx = (time_counter - 1) % 7;

        ReleaseResource(SPIBusResource);
    }
    unsigned long  *tmp ;
    GetEvent(InitTask,tmp);
	WaitEvent(CopterControlReceiveEvent);
    //static int ethernet_events[] = { 1, 7, -1};
	if (time_counter == 1 | time_counter == 7) {
		SetEvent(SignalGatherInitiateTask, CopterControlReceiveEvent);
	}

	ChainTask(SignalGatherInitiateTask);
}


