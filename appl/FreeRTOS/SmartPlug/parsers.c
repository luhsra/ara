#include "parsers.h"
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "client.h"
#include "cloud.h"

typedef int time_t;

uint8_t getUint8FromHexChar(char c)
{
	if (c >= '0' && c <= '9')
		c -= '0';
	else if (c >= 'A' && c <= 'Z')
		c -= ('A' - 10);
	else if (c >= 'a' && c <= 'z')
		c -= ('a' - 10);
	else
		c = 0;

	return (uint8_t)c;
}

void convertPlcPhyAddressToRaw(uint8_t *rawDest, char *asciiSrc)
{
	for (int i = 0; i < 8; i++)
	{
		rawDest[i] = (uint8_t)(getUint8FromHexChar(*asciiSrc) << 4) + (getUint8FromHexChar(*(asciiSrc + 1)));
		asciiSrc += 2;
	}
}

void convertPlcPhyAddressToString(char *asciiDst, uint8_t *rawSrc)
{
	snprintf(asciiDst, 17, "%02X%02X%02X%02X%02X%02X%02X%02X", PLCPHY2STR(rawSrc));
}

void copyString(char *dst, char *src)
{
	int strLen = strlen(src);
	memcpy(dst, src, strLen);
	dst[strLen] = '\0';
}

int composeJsonFromTelemetryData(char *buf, struct MqttData *telemetryData)
{
	char deviceName[33];
	getDeviceNameByPlcPhyAddr(deviceName, telemetryData->clientPhyAddr);
	int index = sprintf(buf, "{\"%s\":[", deviceName);
	uint8_t *data = telemetryData->data;
	for (int i = 0; i < (telemetryData->len) / 10; i++)
	{
		int ts;
		memcpy(&ts, data, sizeof(time_t));
		data += sizeof(time_t);
		int tsMs = ((*(data)&0xFF) << 8) | (*(data + 1) & 0xFF);
		data += 2;
		uint32_t sample;
		memcpy(&sample, data, sizeof(uint32_t));
		data += sizeof(uint32_t);
		index += sprintf(buf + index, "{\"ts\":%d%03d,\"values\":{\"power\":%d}},", ts, tsMs, sample);
	}
	index += sprintf(buf + index - 1, "]}");
	return index - 1;
}

int composeJsonFromNewDevice(char *buf)
{
	return sprintf(buf, "{\"device\":\"%s\"}", clientListEnd->deviceName);
}
