//#include <stm32f1xx_hal.h>
//#include <stm32f1xx_hal_rcc.h>
//#include <stm32f1xx_ll_gpio.h>

#include "LEDThread.h"
#include "common.h"


// Class to encapsulate working with onboard LED(s)
//
// Note: this class initializes corresponding pins in the constructor.
//       May not be working properly if objects of this class are created as global variables

#define GPIOA 1
volatile uint32_t ledStatus = 0xff;
class LEDDriver
{
	const uint32_t pin = 32;
	bool inited = false;
public:
	LEDDriver()
	{

	}

	void init()
	{
		if(inited)
			return;

		//enable clock to the GPIOC peripheral
		//__HAL_RCC_GPIOA_CLK_ENABLE();

		// Init PC 13 as output
		LL_GPIO_SetPinMode(GPIOA, pin, LL_GPIO_MODE_OUTPUT);
		LL_GPIO_SetPinOutputType(GPIOA, pin, LL_GPIO_OUTPUT_PUSHPULL);
		LL_GPIO_SetPinSpeed(GPIOA, pin, LL_GPIO_SPEED_FREQ_LOW);

		inited = true;
	}

	void turnOn()
	{
		LL_GPIO_ResetOutputPin(GPIOA, pin);
	}

	void turnOff()
	{
		LL_GPIO_SetOutputPin(GPIOA, pin);
	}

	void toggle()
	{
		LL_GPIO_TogglePin(GPIOA, pin);
	}
} led;

void blink(uint8_t status)
{
	led.init();

	for(int i=0; i<3; i++)
	{
		led.turnOn();
		if(status & 0x4)
			HAL_Delay(300);
		else
			HAL_Delay(100);
		led.turnOff();

		status <<= 1;

		HAL_Delay(200);
	}
}

void setLedStatus(uint8_t status)
{
	ledStatus = status;
}

void halt(uint8_t status)
{
	led.init();

	while(true)
	{
		blink(status);

		HAL_Delay(700);
	}
}

void vLEDThread(void *pvParameters)
{
	led.init();

	// Just blink once in 2 seconds
	for (;;)
	{
		vTaskDelay(2000);

		if(ledStatus == 0xff)
		{
			led.turnOn();
			vTaskDelay(100);
			led.turnOff();
		}
		else
		{
			blink(ledStatus);
		}

		//		usbDebugWrite("Test\n");w
		//		serialDebugWrite("SerialTest\n");
	}
}
