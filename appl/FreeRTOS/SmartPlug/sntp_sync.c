//#include <espressif/esp_common.h>
//#include <esp/uart.h>

#include "sntp_sync.h"
#include "FreeRTOS.h"
#include "task.h"

//#include <lwip/err.h>
//#include <lwip/sockets.h>
//#include <lwip/sys.h>
//#include <lwip/netdb.h>
//#include <lwip/dns.h>

//#include "sntp/sntp.h"
#include <time.h>
#include "cloud.h"
#include "system.h"

void sntpInit()
{
	char *servers[] = {"0.pl.pool.ntp.org", "1.pl.pool.ntp.org", "2.pl.pool.ntp.org", "3.pl.pool.ntp.org"};
	//printf("Starting SNTP...\n\r");

	//sntp_set_update_delay(5 * 60 * 1000);
	//set_dev_type(devType);
	/* Set GMT+1 zone, daylight savings off */
	//const struct timezone tz = {0, 0};
	/* SNTP initialization */
	//sntp_initialize(&tz);
	/* Servers must be configured right after initialization */
	//sntp_set_servers(servers, sizeof(servers) / sizeof(char*));
}

void sntpTestTask(void *pvParameters)
{
	//sdk_wifi_station_connect();
	//sntpInit();
	//xTaskNotifyGive(xMqttTask);
	while(1) {
		vTaskDelay(pdMS_TO_TICKS(5000));
		time_t ts = time(NULL);
		printf("TIME: %s", ctime(&ts));
	}
}
