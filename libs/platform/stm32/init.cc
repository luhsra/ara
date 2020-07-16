#include <stm32f1xx_hal.h>
#include <stm32f1xx_hal_pwr.h>
#include <stm32f1xx_ll_usart.h>


void SystemClock_Config(void) {
	// Set up external oscillator to 72 MHz
	RCC_OscInitTypeDef RCC_OscInitStruct;
	RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
	RCC_OscInitStruct.HSEState = RCC_HSE_ON;
	RCC_OscInitStruct.LSEState = RCC_LSE_OFF;
	RCC_OscInitStruct.HSIState = RCC_HSI_ON;
	RCC_OscInitStruct.HSICalibrationValue = 16;
	RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
	RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
	RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
	RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
	HAL_RCC_OscConfig(&RCC_OscInitStruct);

	// Set up periperal clocking
	RCC_ClkInitTypeDef RCC_ClkInitStruct;
	RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
	RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
	RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
	RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
	RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
	HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2);

	// Set up USB clock
	RCC_PeriphCLKInitTypeDef PeriphClkInit;
	PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_USB;
	PeriphClkInit.UsbClockSelection = RCC_USBCLKSOURCE_PLL_DIV1_5;
	HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit);

	// Set up SysTTick to 1 ms
	// TODO: Do we really need this? SysTick is initialized multiple times in HAL
	HAL_SYSTICK_Config(HAL_RCC_GetHCLKFreq() / 1000);
	HAL_SYSTICK_CLKSourceConfig(SYSTICK_CLKSOURCE_HCLK);

	// SysTick_IRQn interrupt configuration - setting SysTick as lower priority to satisfy FreeRTOS requirements
	HAL_NVIC_SetPriority(SysTick_IRQn, 15, 0);
}

void InitBoard() {
	HAL_NVIC_SetPriorityGrouping(NVIC_PRIORITYGROUP_4);

	// Initialize board and HAL
	HAL_Init();
	SystemClock_Config();
	// Serial.init();
}

extern "C" void SysTick_Handler(void) {
	HAL_IncTick();
	HAL_SYSTICK_IRQHandler();
}

void StopBoard(void) {
	HAL_PWR_StopQEMU(0);
}

void StopBoard(int status) {
	HAL_PWR_StopQEMU(status);
}

__attribute__((weak)) extern "C" void vApplicationMallocFailedHook( void )
{
	/* vApplicationMallocFailedHook() will only be called if
	configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h.  It is a hook
	function that will get called if a call to pvPortMalloc() fails.*/
	//taskDISABLE_INTERRUPTS();
	LL_USART_TransmitData8(USART2, '?');
	for( ;; );
}

__attribute__((weak)) extern "C" void vApplicationStackOverflowHook( void )
{
	/* vApplicationMallocFailedHook() will only be called if
	configUSE_MALLOC_FAILED_HOOK is set to 1 in FreeRTOSConfig.h.  It is a hook
	function that will get called if a call to pvPortMalloc() fails.*/
	//taskDISABLE_INTERRUPTS();
	LL_USART_TransmitData8(USART2, '?');
	for( ;; );
}

__attribute__((weak)) extern "C" void _init() {}

__attribute__((weak)) extern "C" void vApplicationIdleHook( void ) {}
