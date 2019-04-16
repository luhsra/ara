//#include <espressif/esp_common.h>
//#include <esp8266.h>
//#include <esp/uart.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <FreeRTOS.h>
#include <task.h>
#include "queue.h"
//#include <httpd/httpd.h>
#include "http_server.h"
//#include "jsmn.h"
#include "plc.h"
#include "spiffs_local.h"

enum WebsocketClbkUse{
	NONE,
	SET_CONFIG,
	PLC_FUNCTION
};




volatile struct tcp_pcb{
    int data;
};



void websocket_register_callbacks(tWsOpenHandler ws_open_cb, tWsHandler ws_cb)
{
    struct tcp_pcb wsPCB_tmp;
    uint8_t tmp = 32;
    ws_open_cb(&wsPCB_tmp,"casdf");
    ws_cb(&wsPCB_tmp,&tmp,324,324);

}


typedef  char jsmntok_t;

//websocket_write((struct tcp_pcb *)wsPCB, char*, int, int);

TaskHandle_t xHTTPServerTask;
static TaskHandle_t xWSGetAckTaskHandle = NULL;

volatile enum WebsocketClbkUse websocketClbkUse = NONE;
volatile struct tcp_pcb *wsPCB;

const uint8_t wifiConnectionFailedJson[] = "{\"data\":\"enableButtons\",\"msg\":\"Could not connect.\"}";
const uint8_t wifiWrongPasswordJson[] = "{\"data\":\"enableButtons\",\"msg\":\"Wrong wifi password\"}";
const uint8_t wifiNoAPFoundJson[] = "{\"data\":\"enableButtons\",\"msg\":\"No AP found.\"}";

uint8_t wifiConnectionSuccessJson[] =
	"{\"data\":\"stopWs\",\"msg\":\"Connection successful. Closing access point. \
Save the PLC Phy Address: ----------------\"}";

uint8_t wifiConnectionSuccessJsonLen = sizeof(wifiConnectionSuccessJson) - 1;

// Messages correspond to enumerated type in esp_sta.h (STATION_IDLE, STATION_CONNECTING...)/
const uint8_t *wifiJsonStrings[] = {
	wifiConnectionFailedJson,
	wifiConnectionFailedJson,
	wifiWrongPasswordJson,
	wifiNoAPFoundJson,
	wifiConnectionFailedJson};

// Length of above strings (null character -> so '-1'')
const uint8_t wifiJsonStringsLen[] = {
	sizeof(wifiConnectionFailedJson) - 1,
	sizeof(wifiConnectionFailedJson) - 1,
	sizeof(wifiWrongPasswordJson) - 1,
	sizeof(wifiNoAPFoundJson) - 1,
	sizeof(wifiConnectionFailedJson) - 1};

const uint8_t plcJsonRegisSuccessStr[] =
	"{\"data\":\"stopWs\",\"msg\":\"Succesfully registered client. Closing access point.\"}";
const uint8_t plcJsonRegisUnsuccessStr[] =
	"{\"data\":\"enableButtons\",\"msg\":\"Client registration error. Please, check PLC Phy address.\"}";

const uint8_t plcJsonRegisSuccessStrLen = sizeof(plcJsonRegisSuccessStr) - 1;
const uint8_t plcJsonRegisUnsuccessStrLen = sizeof(plcJsonRegisUnsuccessStr) - 1;

static inline void sendGatewayConfigDataToConfiguratorTask(char *data, jsmntok_t *t);
static inline void sendClientConfigDataToConfiguratorTask(char *data, jsmntok_t *t);

void setConfig(char *data, int len, struct tcp_pcb *pcb)
{
	//jsmn_parser jsmnParser;
	jsmntok_t t[10];
	//jsmn_init(&jsmnParser);
	int r = 34;//jsmn_parse(&jsmnParser, data, len, t, sizeof(t) / sizeof(t[0]));
	if (r < 0)
	{
		printf("JSON Parsing failed\n");
		return;
	}

	char *configStr = data + t[1];
	int configStrLen = t[1] - t[1];

	printf("%.*s\n", configStrLen, configStr);

	if (!strncmp(configStr, "ssid", configStrLen))
		sendGatewayConfigDataToConfiguratorTask(data, t);
	else if (!strncmp(configStr, "phyaddr", configStrLen))
		sendClientConfigDataToConfiguratorTask(data, t);
}

static inline void sendGatewayConfigDataToConfiguratorTask(char *data, char *t)
{
	struct ConfigData configData;

	char *ssid = data + t[2];
	int ssidStrLen = t[2] - t[2];
	char *password = data + t[4];
	int passwordLen = t[4] - t[4];
	char *tbToken = data + t[6];
	char *deviceName = data + t[8];
	int deviceNameLen = t[8] - t[8];

	memcpy(configData.ssid, ssid, ssidStrLen);
	memcpy(configData.password, password, passwordLen);
	memcpy(configData.tbToken, tbToken, 20);
	memcpy(configData.deviceName, deviceName, deviceNameLen);

	configData.ssid[ssidStrLen] = configData.password[passwordLen] =
		configData.tbToken[20] = configData.deviceName[deviceNameLen] = '\0';

	configData.ssidLen = (uint8_t)ssidStrLen;
	configData.passwordLen = (uint8_t)passwordLen;
	configData.deviceNameLen = (uint8_t)deviceNameLen;

	configData.mode = GATEWAY_CONF;

	// Let other task handle this data (this handler should be left asap - it is said by http server documentation)
	xQueueSend(xConfiguratorQueue, &configData, 0);
}

static inline void sendClientConfigDataToConfiguratorTask(char *data, jsmntok_t *t)
{
	struct ConfigData configData;

	char *phyAddr = data + t[2];
	char *deviceName = data + t[4];
	int deviceNameLen = t[4] - t[4];

	memcpy(configData.plcPhyAddr, phyAddr, 16);
	memcpy(configData.deviceName, deviceName, deviceNameLen);

	configData.plcPhyAddr[16] = configData.deviceName[deviceNameLen] = '\0';
	configData.deviceNameLen = (uint8_t)deviceNameLen;

	printf("%s %s\n", configData.plcPhyAddr, configData.deviceName);

	configData.mode = CLIENT_CONF;
	xQueueSend(xConfiguratorQueue, &configData, 0);
}

char *index_cgi_handler(int iIndex, int iNumParams, char *pcParam[], char *pcValue[])
{
	return "/index.html";
}

/**
 * This function is called when websocket frame is received.
 *
 * Note: this function is executed on TCP thread and should return as soon
 * as possible.
 */
void websocket_cb( struct tcp_pcb *pcb, uint8_t *data, int data_len, uint8_t mode)
{
	printf("[websocket_callback]:\n%.*s\n", (int)data_len, (char *)data);

	if (!strncmp((char *)data, "ACK", 3))
	{
		if (xWSGetAckTaskHandle)
			xTaskNotifyGive(xWSGetAckTaskHandle);
		return;
	}

	if (websocketClbkUse == SET_CONFIG)
	{
		setConfig((char *)data, data_len, pcb);
	}
}

/**
 * This function is called when new websocket is open.
 */
void websocket_open_cb( struct tcp_pcb *pcb, const char *uri)
{
	printf("WS URI: %s\n", uri);

	if (!strcmp("/set-config", uri))
	{
		websocketClbkUse = SET_CONFIG;
		printf("Set config\n");
		wsPCB = pcb;
	}
	else
	{
		websocketClbkUse = NONE;
		printf("Uri not found\n\r");
	}
}

void httpd_task(void *pvParameters)
{
	//tCGI pCGIs[] = {
	//	{"/index", (tCGIHandler)index_cgi_handler},
	//};

	/* register handlers and start the server */
	//http_set_cgi_handlers(pCGIs, sizeof(pCGIs) / sizeof(pCGIs[0]));
	websocket_register_callbacks((tWsOpenHandler)websocket_open_cb, (tWsHandler)websocket_cb);
	//httpd_init();

	for (;;)
		;
}

void sendWsResponse(const uint8_t *msg, int len)
{
	//websocket_write((struct tcp_pcb *)wsPCB, msg, len, 123);
}

void sendWsResponseAndWaitForAck(const uint8_t *msg, int len)
{
	// Subscribe to get notification when ACK via websocket will be sent.
	xWSGetAckTaskHandle = xTaskGetCurrentTaskHandle();
	//websocket_write((struct tcp_pcb *)wsPCB, msg, len, 123);
	// Wait for ACK from websocket
	ulTaskNotifyTake(pdTRUE, pdMS_TO_TICKS(10000));
	xWSGetAckTaskHandle = NULL;
}