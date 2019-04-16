#ifndef PARSERS_H
#define PARSERS_H

#include <stdint.h>

struct MqttData;

#define PLCPHY2STR(a) (a)[0], (a)[1], (a)[2], (a)[3], (a)[4], (a)[5], (a)[6], (a)[7]

uint8_t getUint8FromHexChar(char c);
void convertPlcPhyAddressToRaw(uint8_t *rawDest, char *asciiSrc);
void convertPlcPhyAddressToString(char *asciiDst, uint8_t *rawSrc);
void copyString(char *dst, char *src);
int composeJsonFromTelemetryData(char *buf, struct MqttData *telemetryData);
int composeJsonFromNewDevice(char *buf);

#endif