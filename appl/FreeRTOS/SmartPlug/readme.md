# Smartplug

## The system

Let's start with an outline which describes the whole system in which the smartplug is used:

![Smartplug system](doc/img/System.png?raw=true "System")

There is a main smartplug called gateway which gathers data (power samples and relay status) from other smartplugs 
over Power Line Communication. The gateway is connected to local WiFi access point to be connected with remote
Thingsboard server which allows to control the system (switching on/off the devices connected to smartplugs in
the system) and visualize collected data on neat charts.

## The device

This simple outline shows what's inside the device:

![Smartplug simplified](doc/img/Device.png?raw=true "Device")

For the electronic schematic diagram and board of the device ask me by mail.

## How does it work

At first boot the device checks in a local file, which contains information what type of device it is (SPIFFS 
filesystem is used), whether there is something written inside the file. The file can contain string "GATEWAY" or
"CLIENT" or no string. When the file is empty the device knows that it's a first boot so it sets up configuration
environment.

To configure the device at first boot the smartplug starts a WiFi AP and a HTTP server. One can then connect to the
AP and configure the device through a web panel accessible on 192.168.0.1 IP in the LAN created by the smartplug.

The first smartplug in the system must be configured as a gateway. To configure it as a gateway in the web panel those
credentials must be passed:
* target WiFi SSID and corresponding password - the target AP must have Internet access
* Thingsboard access token - which can be obtained 
[in this way](https://thingsboard.io/docs/getting-started-guides/helloworld/#provision-your-device)
* the device name - a name of the device which will be plugged into the smartplug (e.g. a fridge)

After confirming the configuration (web panel has buttons to confirm the credentials) a announcement about the result
of the configuration process will be shown to the user. Normally the device will connect to the target AP and will
start operation. It will connect to the Thingsboard server to transfer data between the system and the remote server.
One must provide Thingsboard server on his own (it could be run on VPS or your local computer - but it must have
public IP).

The next smartplugs must be	configured to work in "client" mode - they will connect to the gateway through PLC to
transfer data. To configure the smartplug as a client those credentials must be passed in the web panel:
* the gateway PLC PHY address - this address will be shown to a user when the gateway configuration will be successful.
* the device name

Client and gateway periodically ask onboard MCP39F501 chip for power samples. For each sample a timestamp is obtained,
because it is needed to make time oriented charts in Thingsboard. The device uses SNTP to determine the current time. 
It connects to remote NTP servers from the global pool through local AP periodically. The smartplug isn't permanently
connected to the WiFi AP for the whole time - it only establishes the connection when it wants to get data from remote
NTP server. 

After collecting a few samples from the power measuring chip those samples are put into PLC packet and sent to the
gateway. The gateway forwards this data to the Thingsboard server using MQTT protocol.

The gateway is subscribed also on a topic on which requests to turn on/off a device are sent. When the Thingsboard
server sends a MQTT message on this topic the gateway resolves which of the device should be switched on or off.
When it's a smartplug working in the client mode it forwards this request over PLC to the corresponding smartplug.
When it's a smartplug working in the gateway mode it doesn't have to forward the request further because the request
corresponds to it.

As we can see the gateway comprises client mode operation. It's functionality is expanded to be also a gate
between the local smartplug system and the remote Thingsboard server.

PLC is used here as a proof of concept. The use of it can be easily removed from the application. The whole system
could simply work only basing on WiFi. 
