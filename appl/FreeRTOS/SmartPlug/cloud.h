#ifndef CLOUD_H
#define CLOUD_H

#include <FreeRTOS.h>
#include <queue.h>

#define MQTT_HOST "172.104.142.37"
#define MQTT_PORT 1883

#define MQTT_ID "ESP_TELEMETRY"
#define MQTT_PASS NULL

#include <FreeRTOS.h>
#include <task.h>

#define TYPE_TELEMETRY			1
#define TYPE_NEW_DEVICE			2
#define TYPE_GPIO_STATUS_GET 	3

struct MqttData
{
	uint8_t data[32];
	uint8_t clientPhyAddr[8];
	uint8_t dataType;
	uint8_t len;
};

enum RpcMethodType
{
	NO_METHOD, GET_GPIO_STATUS, SET_GPIO_STATUS
};

extern QueueHandle_t xMqttQueue;

void mqttTask(void *pvParameters);
void setTbToken(char *);
char *getTbToken();

#endif