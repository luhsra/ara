PROGRAM=Smartplug
PROGRAM_SRC_DIR=/home/kacper/Workspace/ESP8266/Smartplug

EXTRA_CFLAGS=-DLWIP_HTTPD_CGI=1 -DLWIP_HTTPD_SSI=1 -I./fsdata
EXTRA_COMPONENTS=extras/mbedtls extras/httpd extras/dhcpserver extras/jsmn extras/spiffs extras/paho_mqtt_c extras/sntp extras/softuart

#html:
	#/home/ubuntu/Workspace/ESP8266/Smartplug/fsdata/makefsdata

FLASH_SIZE = 32
SPIFFS_BASE_ADDR = 0x200000
SPIFFS_SIZE = 0x010000

include /home/kacper/esp-open-rtos/common.mk

$(eval $(call make_spiffs_image,spiffs_files))