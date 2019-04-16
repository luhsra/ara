#ifndef SPIFFS_LOCAL_H_
#define SPIFFS_LOCAL_H_

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "client.h"

struct ConfigData;

extern const char clientStr[7];
extern const char gatewayStr[7];

int initFileSystem();

void saveConfigDataToFile(struct ConfigData *);
int getDeviceModeFromFile(char *);
void getCredentialsFromFile(char *ssid, char *wifiPassword, 
	char *tbToken, char *plcPhyAddr, char *deviceName);
void saveClientDataToFile(struct Client *newClient);
void retrieveClientListFromFile();
void printFileContent();

#endif