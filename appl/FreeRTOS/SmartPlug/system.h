#ifndef SYSTEM_H
#define SYSTEM_H

#define WIFI_SSID "Juno_"
#define WIFI_PASS "huehuehue"

#define MAX_RETRIES 10

#define CLIENT 1
#define GATEWAY 2

#define MAX_WAITTIME_FOR_DISCONNECT_WHEN_CHANGING_STATION 20

#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

enum ConfigMode
{
    GATEWAY_CONF, CLIENT_CONF
};

struct ConfigData
{
    char ssid[33], password[65], plcPhyAddr[17], tbToken[21], deviceName[33];
	enum ConfigMode mode;
    uint8_t ssidLen, passwordLen, deviceNameLen;
};

struct sdk_station_config{
    int member1;
    int member2;
    
};

extern QueueHandle_t xConfiguratorQueue;
extern TaskHandle_t xConfiguratorTask;

extern volatile int devType;

void configuratorTask(void *pvParameters);

void initDeviceByMode();

void fillStationConfig(struct sdk_station_config *config, char *ssid, char *password, 
	uint8_t ssidLen, uint8_t passwordLen);


#endif