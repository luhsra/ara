#include "../Libs/FreeRTOS/Arduino_FreeRTOS.h"

#include "Screens/ScreenManager.h"
#include "GPS/GPSThread.h"

#include "BoardInit.h"
#include "LEDThread.h"
#include "ButtonsThread.h"
#include "SDThread.h"
#include "USBDebugLogger.h"
#include "SerialDebugLogger.h"
#include "time_markers.h"
//#include "SdMscDriver.h"
/* Core Debug registers */
/*
08003518 <_ZL15stopwatch_resetv>:
 8003518:       4a06            ldr     r2, [pc, #24]   ; (8003534 <_ZL15stopwatch_resetv+0x1c>)
 800351a:       6813            ldr     r3, [r2, #0]
 800351c:       f043 7380       orr.w   r3, r3, #16777216       ; 0x1000000
 8003520:       6013            str     r3, [r2, #0]
 8003522:       4b05            ldr     r3, [pc, #20]   ; (8003538 <_ZL15stopwatch_resetv+0x20>)
 8003524:       2200            movs    r2, #0
 8003526:       601a            str     r2, [r3, #0]
 8003528:       4a04            ldr     r2, [pc, #16]   ; (800353c <_ZL15stopwatch_resetv+0x24>)
 800352a:       6813            ldr     r3, [r2, #0]
 800352c:       f043 0301       orr.w   r3, r3, #1
 8003530:       6013            str     r3, [r2, #0]
 8003532:       4770            bx      lr
 8003534:       e000edfc        strd    lr, [r0], -ip
 8003538:       e0001004        and     r1, r0, r4
 800353c:       e0001000        and     r1, r0, r0

*/
TIME_MARKER(main_reached);
TIME_MARKER(main_hw_init);
TIME_MARKER(main_tasks_created);


// #define DEMCR           (*((volatile uint32_t *)0xE000EDFC))
// #define DWT_CTRL        (*(volatile uint32_t *)0xe0001000)
// #define DEMCR_TRCENA    0x01000000
 #define DWT_CYCCNT      ((volatile uint32_t *)0xE0001004)
 #define CPU_CYCLES      *DWT_CYCCNT
// #define CYCCNTENA       (1<<0)
//
// static __attribute__ ((noinline)) void stopwatch_reset(void)
// {
//     /* Enable DWT */
//     DEMCR |= DEMCR_TRCENA;
//     *DWT_CYCCNT = 0;
//     /* Enable CPU cycle counter */
//     DWT_CTRL |= CYCCNTENA;
// }

int main(void)
{
  //  stopwatch_reset();
  STORE_TIME_MARKER(main_reached);
  InitBoard();
  initDebugSerial();

  portENABLE_INTERRUPTS(); // To allow halt() use HAL_Delay()
  
       
  //  blink(9);
	//  blink(7);
  //	blink(0);
  
  
  // Initialize SD card before initializing USB
  //  if(!initSDIOThread()){
  //    serialDebugWrite("System halted\r\n");
  //halt(7);
  // serialDebugWrite("System halted\r\n");
  //}

	
  //	blink(0);
	/*
	blink(7);
	blink(0);
	*/

  //	initUSB();

	
  //	blink(7);
	/*
	blink(0);
	blink(7);
	*/

	//initDisplay();

	//initScreens();
	//initSDThread();
	//initGPS();
        initButtons();

		//	serialDebugWrite("creating Threads\r\n");
	STORE_TIME_MARKER(main_hw_init);
	// Set up threads
	// TO_not_DO: Consider encapsulating init and task functions into a class(es)
	xTaskCreate(vSDThread, "SD Thread", 512, NULL, tskIDLE_PRIORITY +4 , NULL);
	xTaskCreate(vLEDThread, "LED Thread",	configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 2, NULL);

	xTaskCreate(vDisplayTask, "Display Task", 768, NULL, tskIDLE_PRIORITY + 2, NULL);
	xTaskCreate(vButtonsThread, "Buttons Thread", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY + 2, NULL);
	//	xTaskCreate(xSDIOThread, "SD IO executor", 256, NULL, tskIDLE_PRIORITY + 3, NULL);
	//xTaskCreate(xSDTestThread, "SD test thread", 200, NULL, tskIDLE_PRIORITY + 3, NULL);
	xTaskCreate(vGPSTask, "GPS Task", 256, NULL, tskIDLE_PRIORITY + 3, NULL);
	STORE_TIME_MARKER(main_tasks_created);
	//usbDebugWrite("Test\n");
	//	serialDebugWrite("SerialTest\n\r");
	//	serialDebugWrite("m_start, m_startInits, m_startSched: %d %d %d\r\n",m_start, m_startInits, m_startSched);

	// Run scheduler and all the threads
	vTaskStartScheduler();

	// Never going to be here
	return 0;
}
