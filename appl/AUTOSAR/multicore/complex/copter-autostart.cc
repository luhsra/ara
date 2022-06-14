/**
 * @defgroup apps Applications
 * @brief The applications...
 */

/**
 * @file
 * @ingroup apps
 * @brief Just a simple test application
 */
#include "autosar/os.h"
#include "test/test.h"
#include "machine.h"

void ara_timing_info(int, int);

//extern "C" volatile uint32_t random_source =0 ;
DeclareTask(SignalGatherInitiateTask);
DeclareTask(SignalGatherFinishedTask);
DeclareTask(SignalGatherTimeoutTask);
DeclareTask(SignalProcessingActuateTask);
DeclareTask(SignalProcessingAttitudeTask);
DeclareTask(FlightControlTask);
DeclareTask(FlightControlAttitudeTask);
DeclareTask(FlightControlActuateTask);
DeclareTask(MavlinkSendTask);
DeclareTask(CopterControlTask);
DeclareTask(MavlinkRecvHandler);

DeclareResource(SPIBus);
DeclareResource(SPIBus1);
DeclareSpinlock(SPIBusLock);

DeclareAlarm(CopterControlWatchdogAlarm);

TEST_MAKE_OS_MAIN( StartOS(0) )

int round;

TASK(ControlTask) {
	ara_timing_info(1, 2);
	ActivateTask(SignalGatherInitiateTask);
	ara_timing_info(1, 2);
	ActivateTask(FlightControlTask);
	ara_timing_info(1, 2);
	TerminateTask();
}
	

TASK(SignalGatherInitiateTask) {
	ara_timing_info(1, 2);
	if (round == 9) {
		ara_timing_info(1, 2);
		test_trace(0x00);
		test_finish();
		ShutdownMachine();
	}
	ara_timing_info(1, 2);
	test_trace(0x01);
	GetResource(SPIBus);
	ara_timing_info(1, 1);
	GetSpinlock(SPIBusLock);
	ara_timing_info(2, 4);
	test_trace(0x02);
	if ((round % 2) == 0) {
		ara_timing_info(1, 3);
		ActivateTask(SignalGatherTimeoutTask);
		ara_timing_info(1, 2);
		test_trace(0x03);
	} else {
		ara_timing_info(1, 2);
		ActivateTask(SignalGatherFinishedTask);
		ara_timing_info(1, 2);
		test_trace(0x04);
	}
	ara_timing_info(2, 4);
	round ++;
	test_trace(0x05);
	ReleaseSpinlock(SPIBusLock);
	ara_timing_info(1, 2);
	ReleaseResource(SPIBus);
	ara_timing_info(2, 4);
	test_trace(0x06);
	TerminateTask();
}

TASK(SignalGatherFinishedTask) {
	ara_timing_info(1, 5);
	test_trace(0x11);
	ActivateTask(SignalProcessingAttitudeTask);
	ara_timing_info(1, 2);
	test_trace(0x12);
	ActivateTask(SignalProcessingActuateTask);
	ara_timing_info(1, 2);
	test_trace(0x13);
	TerminateTask();
}

TASK(SignalGatherTimeoutTask) {
	ara_timing_info(1, 3);
	test_trace(0x21);
	GetResource(SPIBus);
	ara_timing_info(1, 2);
	GetSpinlock(SPIBusLock);
	ara_timing_info(1, 8);
	test_trace(0x22);
	ReleaseSpinlock(SPIBusLock);
	ara_timing_info(1, 2);
	ReleaseResource(SPIBus);
	ara_timing_info(1, 5);
	test_trace(0x23);
	ChainTask(SignalGatherFinishedTask);
}

volatile int calculate;

TASK(SignalProcessingActuateTask) {
	ara_timing_info(5, 12);
	test_trace(0x31);
	//for (calculate = 0; calculate < 200; calculate++);
	test_trace(0x30 | (calculate & 0xf));
	TerminateTask();
}

TASK(SignalProcessingAttitudeTask) {
	ara_timing_info(3, 8);
	test_trace(0x41);
	//for (calculate = 0; calculate < 200; calculate++);
	test_trace(0x40 | (calculate & 0xf));
	TerminateTask();
}

TASK(FlightControlTask) {
	ara_timing_info(7, 12);
	test_trace(0x51);
	ActivateTask(FlightControlAttitudeTask);
	ara_timing_info(3, 9);
	test_trace(0x52);
	ActivateTask(FlightControlActuateTask);
	ara_timing_info(9, 13);
	test_trace(0x53);
	ActivateTask(MavlinkSendTask);
	ara_timing_info(1, 3);
	test_trace(0x54);
	TerminateTask();
}

TASK(FlightControlAttitudeTask) {
	ara_timing_info(45, 67);
	test_trace(0x61);
	TerminateTask();
}

TASK(FlightControlActuateTask) {
	ara_timing_info(41, 87);
	test_trace(0x71);
	TerminateTask();
}

TASK(MavlinkSendTask) {
	ara_timing_info(15, 27);
	test_trace(0x81);
	GetResource(SPIBus1);
	ara_timing_info(1, 2);
	GetSpinlock(SPIBusLock);
	ara_timing_info(12, 19);
	test_trace(0x82);
	// Machine::trigger_interrupt_from_user(37);
	ReleaseSpinlock(SPIBusLock);
	ara_timing_info(1, 2);
	ReleaseResource(SPIBus1);
	ara_timing_info(2, 3);
	test_trace(0x83);
	TerminateTask();
}

TASK(CopterControlTask) {
	ara_timing_info(3, 7);
	test_trace(0x91);
	// SuspendAllInterrupts();
	ara_timing_info(2, 6);
	test_trace(0x92);
	// ResumeAllInterrupts();
	ara_timing_info(2, 3);
	test_trace(0x93);
	// if (round < 5) {
	// 	ara_timing_info(1, 3);
	// 	CancelAlarm(CopterControlWatchdogAlarm);
	// 	ara_timing_info(1, 2);
	// 	test_trace(0x94);
	// 	SetRelAlarm(CopterControlWatchdogAlarm, 110, 100);
	// 	ara_timing_info(1, 2);
	// }
	ara_timing_info(1, 3);
	test_trace(0x95);

	TerminateTask();
}

ISR2(MavLinkRecvHandler) {
	ara_timing_info(1, 2);
#ifndef CONFIG_ARCH_OSEK_V
	test_trace(0xA1);
#endif

	ActivateTask(CopterControlTask);
#ifndef CONFIG_ARCH_OSEK_V
	test_trace(0xA2);
#endif
}

TASK(CopterControlWatchdogTask) {
	ara_timing_info(3, 6);
	test_trace(0xB1);
	TerminateTask();
}


void PreIdleHook() {
	kout << "I" << round << endl;
}

#if LOCKS_JSON
{"no_timing": {"spin_states": {"SPIBusLock": 10}}, "with_timing": {"spin_states": {"SPIBusLock": 0}}}
#endif // LOCKS_JSON
