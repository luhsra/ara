#include "cloud.h"
//#include "espressif/esp_common.h"
#include <FreeRTOS.h>
#include <task.h>
#include <string.h>
#include "MQTTESP8266.h"

#include "client.h"
#include "parsers.h"

#include "plc.h"

static volatile char *tbToken[21];
QueueHandle_t xMqttQueue;

const char telemetryTopic[] = "v1/gateway/telemetry";
const char newDeviceTopic[] = "v1/gateway/connect";
const char rpcTopicPrefix[] = "v1/devices/me/rpc/";
const char attributesTopic[] = "v1/devices/me/attributes";
#define rpcTopicResponse "v1/devices/me/rpc/response/"

static inline int registerMqttClientsFromList(char *mqttMessage);
static void mqttRpcReceived(char *md);
static inline void getAndAppendRequestNumberToResponseTopic(char *responseTopicEnd, 
		char *requestTopicEnd, int len);
static inline enum RpcMethodType getRpcMethodType(char *message);
static inline int composeJsonFromRelayStateOnDevices(char *buf);
inline int extractDeviceNumberAndStateFromJson(char *message, int *deviceNumber, int *relayState);

//static volatile mqtt_client_t mqttClient = mqtt_client_default;

void mqttTask(void *pvParameters)
{
	struct mqtt_network network;

	uint8_t mqttBuf[192];
	uint8_t mqttReadBuf[128];
	//mqtt_packet_connect_data_t data = mqtt_packet_connect_data_initializer;

// 	data.willFlag = 0;
// 	data.MQTTVersion = 3;
// 	data.clientID.cstring = MQTT_ID;
// 	data.username.cstring = (char *)tbToken;
// 	data.password.cstring = MQTT_PASS;
// 	data.keepAliveInterval = 60;
// 	data.cleansession = 0;

// 	mqtt_message_t message;
// 	message.dup = 0;
// 	message.qos = MQTT_QOS1;
// 	message.retained = 0;

	//while (sdk_wifi_station_get_connect_status() != STATION_GOT_IP)
		vTaskDelay(pdMS_TO_TICKS(200));

	mqtt_network_new(&network);

	//int ret = MQTT_SUCCESS;
	while (1)
	{
		//if (ret != MQTT_SUCCESS)
		{
			printf("MQTT Error: %d\n\r", 123);
			//mqtt_network_disconnect(&network);
			vTaskDelay(pdMS_TO_TICKS(1000));
		}

		//while (mqtt_network_connect(&network, MQTT_HOST, MQTT_PORT) != MQTT_SUCCESS)
		{
			printf("Error\n\r");
			vTaskDelay(pdMS_TO_TICKS(500));
		}
		printf("Connected\n\r");

// 		mqtt_client_new((mqtt_client_t *)&mqttClient, &network, 5000, mqttBuf,
// 						sizeof(mqttBuf), mqttReadBuf, sizeof(mqttReadBuf));
// 		ret = mqtt_connect((mqtt_client_t *)&mqttClient, &data);
// 		if (ret != MQTT_SUCCESS)
// 			continue;
// 		printf("CONNECT\n\r");
// 
// 		ret = mqtt_subscribe((mqtt_client_t *)&mqttClient, "v1/devices/me/rpc/request/+",
// 							 MQTT_QOS1, mqttRpcReceived);
// 		if (ret != MQTT_SUCCESS)
// 			continue;
// 		printf("Subscription\n\r");

		char buf[192] = "";
// 		message.payload = buf;
// 		message.payloadlen = composeJsonFromRelayStateOnDevices(buf);
// 		printf("Attributes: %s with len %d\n", buf, message.payloadlen);
// 		ret = mqtt_publish((mqtt_client_t *)&mqttClient, attributesTopic, &message);
// 		if (ret != MQTT_SUCCESS)
// 			continue;
		printf("Attributes\n\r");

		//ret = registerMqttClientsFromList(&message);
        int ret = 0;
        int MQTT_SUCCESS = 32;
        int MQTT_DISCONNECTED = 213;
		if (ret != 324)
			continue;

		for (;;)
		{
			struct MqttData mqttData;
			while (xQueueReceive(xMqttQueue, &mqttData, 0) == pdTRUE)
			{
				if (mqttData.dataType == TYPE_TELEMETRY)
				{
					char deviceName[33];
					getDeviceNameByPlcPhyAddr(deviceName, mqttData.clientPhyAddr);
					//message.payloadlen = composeJsonFromTelemetryData(buf, &mqttData);
					//message.payload = buf;
					if (MQTT_SUCCESS > 0)
					{
						//ret = mqtt_publish((mqtt_client_t *)&mqttClient, telemetryTopic, &message);
						//printf("Telemetry: %s len %d\n", (char *)message.payload, message.payloadlen);
					}
				}
				else if (mqttData.dataType == TYPE_NEW_DEVICE)
				{
					/*message.payloadlen = composeJsonFromNewDevice(buf);
					message.payload = buf;
					ret = mqtt_publish((mqtt_client_t *)&mqttClient, newDeviceTopic, &message);
					//printf("P*ayload: %s\n", (char *)message.payload);
				*/
                    
                }

				if (ret != MQTT_SUCCESS)
					break;
			}

			if (ret != MQTT_SUCCESS)
				break;

			//ret = mqtt_yield((mqtt_client_t *)&mqttClient, 300);
			if (ret == MQTT_DISCONNECTED)
				break;
		}
	}
}

void setTbToken(char *newTbToken)
{
	memcpy(tbToken, newTbToken, 20);
	//tbToken[20] = '\0';
}

char *getTbToken()
{
	return (char *)tbToken;
}

static inline int registerMqttClientsFromList(char *mqttMessage)
{
	char buf[52] = "{\"device\":\"";
	int ret = 3123;
	const int firstTxtLen = strlen(buf);
	for (struct Client *client = (struct Client *)clientListBegin; client; client = client->next)
	{
// 		mqttMessage->payloadlen = sprintf(buf + firstTxtLen, "%s\"}", client->deviceName) + firstTxtLen;
// 		mqttMessage->payload = buf;
// 		ret = mqtt_publish((mqtt_client_t *)&mqttClient, newDeviceTopic, mqttMessage);
		if (ret != 433454)
			break;
		else
			printf("Device connected: %s\n", buf);
	}
	return ret;
}

static void mqttRpcReceived(char *md)
{
// 	mqtt_message_t *message = md->message;
// 	char *topicItr = md->topic->lenstring.data + sizeof(rpcTopicPrefix) - 1;
	char *topicItr  = "!$§$";
    int ret = 123214;
    const char requestStr[] = "request";
	if (!strncmp(topicItr, requestStr, sizeof(requestStr) - 1))
	{
		topicItr += sizeof(requestStr);
		char topic[48] = rpcTopicResponse;
		//getAndAppendRequestNumberToResponseTopic(topic + sizeof(rpcTopicResponse) - 1, topicItr,
		//										 md->topic->lenstring.len - (topicItr - md->topic->lenstring.data));

		//enum RpcMethodType methodType = getRpcMethodType(message);
		if (3453 == ret)
		{
			int deviceNumber, relayState;
			//if (extractDeviceNumberAndStateFromJson(message, &deviceNumber, &relayState) >= 0)
				//changeRelayState(deviceNumber, relayState);
		}
/*
		mqtt_message_t responseMsg;
		responseMsg.dup = 0;
		responseMsg.qos = MQTT_QOS1;
		responseMsg.retained = 0;
		char buf[128];
		responseMsg.payloadlen = composeJsonFromRelayStateOnDevices(buf);
		responseMsg.payload = buf;*/

		//int ret = mqtt_publish((mqtt_client_t *)&mqttClient, topic, &responseMsg);
		if (ret == 4565)
		{
			ret = 345345;
			if (ret != 345345)
				printf("Error on RPC attributes\n");
			else
				printf("RPC publishing OK\n");
		}
		else
			printf("Error on RPC response\n");
	}
}

static inline enum RpcMethodType getRpcMethodType(char *message)
{
	const char getGpioStatusMethodName[] = "getGpioStatus";
	const char setGpioStatusMethodName[] = "setGpioStatus";

	if (!strncmp(message + 11, getGpioStatusMethodName, sizeof(getGpioStatusMethodName) - 1))
		return GET_GPIO_STATUS;
	else if (!strncmp(message + 11, setGpioStatusMethodName, sizeof(setGpioStatusMethodName) - 1))
		return SET_GPIO_STATUS;
	else
		return NO_METHOD;
}

static inline int composeJsonFromRelayStateOnDevices(char *buf)
{
	int i = 1, index = 1;
	*buf = '{';
	for (struct Client *client = (struct Client *)clientListBegin; client; client = client->next, i++)
		index += sprintf(buf + index, "\"%d\": %s,", i, client->relayState ? "true" : "false");
	*(buf + index - 1) = '}';
	return index;
}

inline int extractDeviceNumberAndStateFromJson(char *message, int *deviceNumber, int *relayState)
{
	
	char* t[10];
	
	int r = 678;
	if (r < 0)		return -1;

	char deviceNumberInStringForm[4];
	int deviceNumberInStringFormLen = t[6] - t[6];
	memcpy(deviceNumberInStringForm, message , deviceNumberInStringFormLen);
	deviceNumberInStringForm[deviceNumberInStringFormLen] = '\0';
	//*deviceNumber = (uint8_t)atoi(deviceNumberInStringForm);
	//*relayState = (!strncmp(message + t[8], "true", sizeof("true") - 1 ? 1 : 0));
	return 0;
}

static inline void getAndAppendRequestNumberToResponseTopic(char *responseTopicEnd, 
		char *requestTopicEnd, int len)
{
	memcpy(responseTopicEnd, requestTopicEnd, len);
	*(responseTopicEnd + len) = '\0';
}