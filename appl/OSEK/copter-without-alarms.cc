/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "source/os/os.h"
#include "source/test/test.h"



//extern "C" volatile uint32_t random_source =0 ;
DeclareTask(SignalGatherInitiateTask);
DeclareTask(SignalGatherFinishedTask);
DeclareTask(SignalGatherTimeoutTask);
DeclareTask(SignalProcessingActuateTask);
DeclareTask(SignalProcessingAttitudeTask);
DeclareTask(ActuateTask);
DeclareTask(FlightControlAttitudeTask);
DeclareTask(FlightControlActuateTask);
DeclareTask(FlightControlTask);
DeclareTask(MavlinkSendTask);
DeclareTask(CopterControlTask);
DeclareTask(CopterControlWatchdogTask);
DeclareTask(MavlinkRecvHandler);

DeclareResource(SPIBus);


//TEST_MAKE_OS_MAIN( StartOS(0) )

int round;

TASK(SignalGatherInitiateTask) {
	if (round == 9) {
		test_trace(0x00);
		test_finish();
		ShutdownMachine();
	}
	test_trace(0x01);
	GetResource(SPIBus);
	test_trace(0x02);
	if ((round % 2) == 0) {
		ActivateTask(SignalGatherTimeoutTask);
		test_trace(0x03);
	} else {
		ActivateTask(SignalGatherFinishedTask);
		test_trace(0x04);
	}
	round ++;
	test_trace(0x05);
	ReleaseResource(SPIBus);
	test_trace(0x06);
	TerminateTask();
}

TASK(SignalGatherFinishedTask) {
	test_trace(0x11);
	ActivateTask(SignalProcessingAttitudeTask);
	test_trace(0x12);
	ActivateTask(SignalProcessingActuateTask);
	test_trace(0x13);
	TerminateTask();
}

TASK(SignalGatherTimeoutTask) {
	test_trace(0x21);
	GetResource(SPIBus);
	test_trace(0x22);
	ReleaseResource(SPIBus);
	test_trace(0x23);
	ChainTask(SignalGatherFinishedTask);
}

volatile int calculate;

TASK(SignalProcessingActuateTask) {
	test_trace(0x31);
	//for (calculate = 0; calculate < 200; calculate++);
	test_trace(0x30 | (calculate & 0xf));
	TerminateTask();
}

TASK(SignalProcessingAttitudeTask) {
	test_trace(0x41);
	//for (calculate = 0; calculate < 200; calculate++);
	test_trace(0x40 | (calculate & 0xf));
	TerminateTask();
}

TASK(FlightControlTask) {
	test_trace(0x51);
	ActivateTask(FlightControlAttitudeTask);
	test_trace(0x52);
	ActivateTask(FlightControlActuateTask);
	test_trace(0x53);
	ActivateTask(MavlinkSendTask);
	test_trace(0x54);
	TerminateTask();
}

TASK(FlightControlAttitudeTask) {
	test_trace(0x61);
	TerminateTask();
}

TASK(FlightControlActuateTask) {
	test_trace(0x71);
	TerminateTask();
}

TASK(MavlinkSendTask) {
	test_trace(0x81);
	GetResource(SPIBus);
	test_trace(0x82);
	Machine::trigger_interrupt_from_user(37);
	ReleaseResource(SPIBus);
	test_trace(0x83);
	TerminateTask();
}

TASK(CopterControlTask) {
	test_trace(0x91);
	SuspendAllInterrupts();
	test_trace(0x92);
	ResumeAllInterrupts();
	test_trace(0x93);
	/* if (round < 5) {
		CancelAlarm(CopterControlWatchdogAlarm);
		test_trace(0x94);
		SetRelAlarm(CopterControlWatchdogAlarm, 110, 100);
        } */
	test_trace(0x95);

	TerminateTask();
}

TASK(CopterControlWatchdogTask) {
    test_trace(0xB1);
    TerminateTask();
}

ISR2(MavlinkRecvHandler) {
	ActivateTask(CopterControlTask);
}

ISR2(AlarmSignalGatherInitiateTask) {
    ActivateTask(SignalGatherInitiateTask);
}

ISR2(AlarmFlightControlTask) {
    ActivateTask(FlightControlTask);
}

ISR2(AlarmCopterControlWatchdogTask) {
    ActivateTask(CopterControlWatchdogTask);
}




void PreIdleHook() {
    static int counter = 0;
 again:
    counter ++;
    kout << "I" << round << counter << endl;
    if (counter % 3 == 0) {
        Machine::trigger_interrupt_from_user(40);
    }
    if (counter % 9 == 0) {
        Machine::trigger_interrupt_from_user(41);
    }
    if (counter == 20) {
        Machine::trigger_interrupt_from_user(42);
    }
    goto again;
}


int  main(void){
    char * appmode = {"tmp"};
    StartOS(appmode);
    return 0;
}
