#ifndef CLIENT_H
#define CLIENT_H

#include <stdio.h>
#include <stdint.h>
#include "FreeRTOS.h"
#include "task.h"

struct Client {
	struct Client *next;
	uint8_t plcPhyAddr[8];		// PLC Physical address is binary data.
	char deviceName[32 + 1]; 	// Thingsboard token is an ascii type string so null termination is required
	uint8_t relayState;
};

extern volatile struct Client *clientListBegin;
extern volatile struct Client *clientListEnd;
extern volatile int clientCnt;

void addClient(struct Client *client);
struct Client *createClient(uint8_t *plcPhyAddr, char *deviceName, int deviceNameLen);
struct Client *createClientFromString(char *plcPhyAddr, char *deviceName, int deviceNameLen);
void getDeviceNameByPlcPhyAddr(char *destDeviceName, uint8_t *srcPlcPhyAddr);

#endif