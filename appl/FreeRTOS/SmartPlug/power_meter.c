#include "power_meter.h"
//#include "espressif/esp_common.h"
#include "FreeRTOS.h"
#include "task.h"
//#include "esp8266.h"
#include "plc.h"
#include "system.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
//#include <esp/gpio.h>
//#include <espressif/esp_common.h>
#include "cloud.h"
#include "client.h"
//#include <softuart/softuart.h>

extern void softuart_open(int, int, int, int);
extern int softuart_read(int);
extern void softuart_close(int);
extern void softuart_nputs(int,const char*,int);
extern bool softuart_available(int);
#define pdTICKS_TO_MS(x) (x) * ((TickType_t)1000) / ((TickType_t)configTICK_RATE_HZ)

#define RX_PIN 12
#define TX_PIN 14

static int getSSIPacket(uint8_t *buf, TickType_t *lastWakeTime);

void getPowerTask(void *pvParameters)
{
	struct MqttData telemetryData;
	memcpy(telemetryData.clientPhyAddr, (uint8_t *)clientListBegin->plcPhyAddr, 8);
	telemetryData.dataType = TYPE_TELEMETRY;
	const char commandGetPower[] = {0xA5, 0x07, 0x41, 0x00, 0x0A, 0x44, 0x3B};
	int index = 0;

	softuart_open(0, 4800, RX_PIN, TX_PIN);
	vTaskDelay(pdMS_TO_TICKS(10000));
	TickType_t lastWakeTime = xTaskGetTickCount();
	while (true)
	{
		vTaskDelayUntil(&lastWakeTime, pdMS_TO_TICKS(1250));
		softuart_nputs(0, commandGetPower, sizeof(commandGetPower));
		uint8_t rcvArray[8];
		int len = getSSIPacket(rcvArray, &lastWakeTime);
		if (len < 0)
		{
			printf("Error sending packet\n");
			softuart_close(0);
			vTaskDelayUntil(&lastWakeTime, pdMS_TO_TICKS(400));
			softuart_open(0, 4800, RX_PIN, TX_PIN);
		}
		else if (len == 7)
		{
			time_t timestamp = time(NULL);
			memcpy(&telemetryData.data[index], &timestamp, sizeof(time_t));
			index += sizeof(time_t);

			int tsMs = ((int)pdTICKS_TO_MS(xTaskGetTickCount())) % 1000;
			telemetryData.data[index++] = (tsMs >> 8) & 0xFF;
			telemetryData.data[index++] = tsMs & 0xFF;

			uint32_t sample = ((rcvArray[0] & 0xFF) << 24) | ((rcvArray[1] & 0xFF) << 16) | 
				((rcvArray[2] & 0xFF) << 8) | (rcvArray[3] & 0xFF);
			memcpy((uint32_t *)&telemetryData.data[index], &sample, sizeof(uint32_t));
			index += sizeof(uint32_t);

			if (index >= 30)
			{
				printf("Sending power samples\n\r");
				telemetryData.len = index;
				if (devType == CLIENT)
					sendPlcData(telemetryData.data, NULL, NULL, NEW_TELEMETRY_DATA, index);
				else
					xQueueSend(xMqttQueue, &telemetryData, 0);
				index = 0;
			}
		}
	}
}

static int getSSIPacket(uint8_t *buf, TickType_t *lastWakeTime)
{
	vTaskDelayUntil(lastWakeTime, pdMS_TO_TICKS(70));
	if (!softuart_available(0))
		vTaskDelayUntil(lastWakeTime, pdMS_TO_TICKS(5));

	int head = softuart_read(0) & 0xFF;
	if (head != 0x06)
		return -1;

	if (!softuart_available(0))
		vTaskDelayUntil(lastWakeTime, pdMS_TO_TICKS(5));

	int len = softuart_read(0) & 0xFF;
	head = len - 3;
	while (head--)
	{
		if (!softuart_available(0))
			vTaskDelayUntil(lastWakeTime, pdMS_TO_TICKS(5));
		*buf++ = softuart_read(0);
	}

	if (!softuart_available(0))
		vTaskDelayUntil(lastWakeTime, pdMS_TO_TICKS(5));
	softuart_read(0);

	return len;
}