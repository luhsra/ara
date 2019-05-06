#include "client.h"
#include <stdio.h>
#include <string.h>
#include "FreeRTOS.h"
#include "parsers.h"

// TODO: Parse PLC Phy address to two integers composing a key
volatile struct Client *clientListBegin = NULL;
volatile struct Client *clientListEnd = NULL;

struct Client *createClient(uint8_t *plcPhyAddr, char *deviceName, int deviceNameLen)
{
	struct Client *newClient = (struct Client *)pvPortMalloc(sizeof(struct Client));
	memcpy(newClient->plcPhyAddr, plcPhyAddr, 8);
	memcpy(newClient->deviceName, deviceName, deviceNameLen);
	newClient->deviceName[deviceNameLen] = '\0';
	newClient->next = NULL;
	newClient->relayState = 0;
	return newClient;
}

struct Client *createClientFromString(char *plcPhyAddr, char *deviceName, int deviceNameLen)
{
	uint8_t rawPlcPhyAddr[8];
	convertPlcPhyAddressToRaw(rawPlcPhyAddr, plcPhyAddr);
	return createClient(rawPlcPhyAddr, deviceName, deviceNameLen);
}

void addClient(struct Client *client)
{
	if (clientListBegin == NULL)
	{
		clientListBegin = clientListEnd = client;
		return;
	}

	clientListEnd->next = client;
	clientListEnd = client;
}

void getDeviceNameByPlcPhyAddr(char *destDeviceName, uint8_t *srcPlcPhyAddr)
{
	struct Client *client = (struct Client *) clientListBegin;
	while(client)
	{
		int i;
		for(i = 0 ; i < 8 ; i ++)
		{
			if(srcPlcPhyAddr[i] != client->plcPhyAddr[i])
				break;
		}

		if(i == 8)
		{
			copyString(destDeviceName, client->deviceName);
			break;
		}

		client = client->next;
	}
}