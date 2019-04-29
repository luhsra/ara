#ifndef PLC_H
#define PLC_H

#define I2C_ADDR_PIN_FLOATING 1
// #define HOST_INT_PORT
// #define HOST_INT_PIN
// #define HOST_INT_NR
#define BUS_FREE_TIME_BEFORE_STO_STA 550

#if I2C_ADDR_PIN_FLOATING
#define PLC_READ_ADDR 0x02
#define PLC_WRITE_ADDR 0x01
#else
#define PLC_READ_ADDR 0xF5
#define PLC_WRITE_ADDR 0xF4
#endif

// Rejestry nadajnika modemu PLC
#define INTERRUPT_ENABLE_REG 0x00
#define INT_CLEAR_PLC (1 << 7)
#define INT_POLARITY_HIGH (0 << 6)
#define INT_POLARITY_LOW (1 << 6)
#define INT_UNABLE_TO_TX (1 << 5)
#define INT_TX_NO_ACK (1 << 4)
#define INT_TX_NO_RESP (1 << 3)
#define INT_RX_PACKET_DROPPED (1 << 2)
#define INT_RX_DATA_AVAILABLE (1 << 1)
#define INT_TX_DATA_SENT (1 << 0)

#define LOGICAL_ADDR_LSB_REG 0x01
#define LOGICAL_ADDR_MSB_REG 0x02
#define GROUP_ADDR_REG 0x03
#define LOCAL_GROUP_HOT_REG 0x04
#define PLC_MODE_REG 0x05

#define TX_ENABLE (1 << 7)
#define RX_ENABLE (1 << 6)
#define LOCK_CONFIGURATION (1 << 5)
#define DISABLE_BIU (1 << 4)
#define ENABLE_BIU (0 << 4)
#define RX_OVERRIDE (1 << 3)
#define SET_EXT_ADDRESS (1 << 2)
#define ACCEPT_ALL_MSGS (1 << 1)
#define CHECK_DA (0 << 1)
#define DISCARD_PACKET_CRC8 (1 << 0)
#define VERIFY_PACKET_CRC8 (0 << 0)

#define TX_MESSAGE_LENGTH_REG 0x06
#define SEND_MESSAGE (1 << 7)
#define PAYLOAD_LENGTH_MASK 0x1F

#define TX_CONFIG_REG 0x07
#define TX_ADDR_MASK 0b11100000
#define TX_SA_TYPE_LOGICAL (0 << 7)
#define TX_SA_TYPE_PHYSICAL (1 << 7)
#define TX_DA_TYPE_LOGICAL (0 << 5)
#define TX_DA_TYPE_GROUP (1 << 5)
#define TX_DA_TYPE_PHYSICAL (2 << 5)
#define TX_SERVICE_ACKNOWLEDGED (1 << 4)
#define TX_SERVICE_TYPE_NO_ACKNOWLEDGED (0 << 4)

#define TX_DA_REG 0x08
#define TX_COMMAND_ID_REG 0x10
#define TX_DATA_REG 0x11

//Rejestry konfiguracyjne modemu PLC
#define THRESHOLD_NOISE_REG 0x30
#define AUTO_BIU_DISABLED (0 << 6)
#define AUTO_BIU_ENABLED (1 << 6)
#define BIU_TRESHOLD_70DBUV 0x00
#define BIU_TRESHOLD_75DBUV 0x01
#define BIU_TRESHOLD_80DBUV 0x02
#define BIU_TRESHOLD_87DBUV 0x03
#define BIU_TRESHOLD_90DBUV 0x04
#define BIU_TRESHOLD_93DBUV 0x05
#define BIU_TRESHOLD_96DBUV 0x06
#define BIU_TRESHOLD_99DBUV 0x07

#define MODEM_CONFIG_REG 0x31
#define TX_DELAY_7MS (0 << 5)
#define TX_DELAY_13MS (1 << 5)
#define TX_DELAY_19MS (2 << 5)
#define TX_DELAY_25MS (3 << 5)
#define MODEM_FSK_BAND_DEV_3KHZ (1 << 3)   // 133.3:130.4 kHz
#define MODEM_FSK_BAND_DEV_1_5KHZ (0 << 3) // 133.3:131.8 kHz
#define MODEM_BPS_600 0x00
#define MODEM_BPS_1200 0x01
#define MODEM_BPS_1800 0x02
#define MODEM_BPS_2400 0x03

#define TX_GAIN_REG 0x32
#define TX_GAIN_LEVEL_55MV 0x00
#define TX_GAIN_LEVEL_75MV 0x01
#define TX_GAIN_LEVEL_100MV 0x02
#define TX_GAIN_LEVEL_125MV 0x03
#define TX_GAIN_LEVEL_180MV 0x04
#define TX_GAIN_LEVEL_250MV 0x05
#define TX_GAIN_LEVEL_360MV 0x06
#define TX_GAIN_LEVEL_480MV 0x07
#define TX_GAIN_LEVEL_660MV 0x08
#define TX_GAIN_LEVEL_900MV 0x09
#define TX_GAIN_LEVEL_1250MV 0x0A
#define TX_GAIN_LEVEL_1550MV 0x0B //Default
#define TX_GAIN_LEVEL_2250MV 0x0C
#define TX_GAIN_LEVEL_3000MV 0x0D
#define TX_GAIN_LEVEL_3500MV 0x0E

#define RX_GAIN_REG 0x33
#define RX_GAIN_LEVEL_5000UV 0x00 //Default
#define RX_GAIN_LEVEL_3500UV 0x01
#define RX_GAIN_LEVEL_2500UV 0x02
#define RX_GAIN_LEVEL_1250UV 0x03
#define RX_GAIN_LEVEL_600UV 0x04
#define RX_GAIN_LEVEL_350UV 0x05
#define RX_GAIN_LEVEL_250UV 0x06
#define RX_GAIN_LEVEL_125UV 0x07

//  Rejestry odbiornika modemu PLC
#define RX_MESSAGE_INFO_REG 0x40
#define NEW_PACKET_RECEIVED (1 << 7)
#define NO_PACKET_RECEIVED (0 << 7)
#define RX_DA_TYPE_LOGICAL_PHYSICAL (0 << 6)
#define RX_DA_TYPE_GROUP (1 << 6)
#define RX_SA_TYPE_LOGICAL (0 << 5)
#define RX_SA_TYPE_PHYSICAL (1 << 5)
#define RX_MESSAGE_LENGTH_BIT_MASK 0b11111

#define RX_SA_REG 0x41
#define RX_COMMAND_ID_REG 0x49
#define RX_DATA_REG 0x4A

#define INTERRUPT_STATUS_REG 0x69
#define STATUS_VALUE_CHANGE (1 << 7)
#define STATUS_BUSY (1 << 5) //BIU timeout
#define STATUS_TX_NO_ACK (1 << 4)
#define STATUS_TX_NO_RESP (1 << 3)
#define STATUS_RX_PACKET_DROPPED (1 << 2)
#define STATUS_RX_DATA_AVAILABLE (1 << 1)
#define STATUS_TX_DATA_SENT (1 << 0)

#define changeRelayStateLocal(X) gpio_write(3, (X))

#include <stdint.h>

enum CustomPlcCommands {
	REGISTER_NEW_DEV = 0x30,
	REGISTRATION_FAILED,
	REGISTRATION_SUCCESS,
	NEW_WIFI_SSID,
	NEW_WIFI_PASSWORD,
	NEW_TB_TOKEN,
	NEW_TELEMETRY_DATA,
	CHANGE_RELAY_STATE
};

enum PlcErr
{
	PLC_ERR_OK = 0,
	PLC_ERR_TIMEOUT = -1,
	PLC_ERR_NO_ACK = -2,
	PLC_ERR_NO_RESP = -3,
	PLC_ERR_REGISTRATION_FAILED = -4,
	PLC_ERR_NOT_WIFI_CREDS = -5,
	PLC_ERR_IDLE = -6,
	PLC_ERR_NEW_SSID = 1,
	PLC_ERR_NEW_PASSWORD = 2,
	PLC_ERR_NEW_TB_TOKEN = 3
};

#define PHY_ADDR 0x6A

#define MASTER_GROUP_ADDR 10

#define MAX_I2C_ATTEMPTS 5

#define MAX_REMOTE_CMD_RETRIES 5
#define MAX_NACK_RCV 2

#include <stdint.h>
#include "FreeRTOS.h"
#include "task.h"
#include "system.h"

#define PLC_TX_BUF_SIZE 8
#define PLC_TX_BUF_MASK (PLC_TX_BUF_SIZE - 1)

typedef long time_t;

enum PlcCommandIds {
	SET_REMOTE_TX_ENABLE = 1,
	SET_REMOTE_RESET,
	SET_REMOTE_EXTENDED_ADDR,
	SET_REMOTE_LOGICAL_ADDR,
	GET_REMOTE_LOGICAL_ADDR,
	GET_REMOTE_PHYSICAL_ADDR,
	GET_REMOTE_STATE,
	GET_REMOTE_VERSION,
	SEND_REMOTE_DATA,
	REQUEST_REMOTE_DATA,
	RESPONSE_REMOTE_DATA,
	SET_REMOTE_BIU,
	SET_REMOTE_THRESHOLD_VALUE,
	SET_REMOTE_GROUP_MEMBERSHIP,
	GET_REMOTE_GROUP_MEMBERSHIP
};

struct PlcTxRecord
{
	uint8_t data[32];
	uint8_t phyAddr[8];
	TaskHandle_t taskToNotify;
	uint8_t command;
	uint8_t len;
};

extern struct PlcTxRecord plcTxBuf[PLC_TX_BUF_SIZE];
extern int plcTxBufHead, plcTxBufTail;

extern TaskHandle_t xPLCTaskRcv;
extern TaskHandle_t xPLCTaskSend;
extern SemaphoreHandle_t xPLCSendSemaphore;

// Poniższe funkcje pochodzą z artykułu AVT5490 - Elektronika Praktyczna
uint8_t readPLCregister(uint8_t reg);
void readPLCregisters(uint8_t reg, uint8_t *buf, uint32_t len);
void writePLCregister(uint8_t reg, uint8_t val);
void writePLCregisters(uint8_t *buf, uint8_t len);

void setPLCtxAddrType(uint8_t txSAtype, uint8_t txDAtype);
void setPLCtxDA(uint8_t txDAtype, uint8_t *txDA);

void fillPLCTxData(uint8_t *buf, uint8_t len);
void setPLCnodeLA(uint8_t logicalAddress);
void setPLCnodeGA(uint8_t groupAddress);
void getPLCrxAddrType(uint8_t *rxSAtype, uint8_t *rxDAtype);
void getPLCrxSA(uint8_t *rxSA);
void readPLCrxPacket(uint8_t *rxCommand, uint8_t *rxData, uint8_t *rxDataLength);
uint8_t readPLCintRegister(void);
void initPLCdevice(uint8_t nodeLA);

#define setPlcPhyAddrFromPLCChip(X) readPLCregisters(PHY_ADDR, (uint8_t *)(X), 8)

void initPlcTask(void *pvParameters);
void plcTaskRcv(void *pvParameters);
void plcTaskSend(void *pvParameters);
void registerNewClientTask(void *pvParameters);

enum PlcErr sendPlcData(uint8_t *data,	uint8_t *phyAddr, TaskHandle_t taskToNotify, 
	uint8_t command, uint8_t len);

enum PlcErr registerClient(struct ConfigData *configData);
void sendMeasurementDataToGatewayOverPLC(time_t ts, uint32_t *data, uint8_t len);	
void initPlcWithDelay();
void changeRelayState(int deviceNumber, int relayState);

#endif
