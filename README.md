# rudelblinken

Synced blinking catears

## Notes

Less of a Readme, more a unstructured braindump

## Hardware

rudelblinken is based on ESP32-C3 supermicro boards. Each device controls a single color LED strip. This should keep the hardware setup quite, simple requiring only a esp board, a mosfet, an LED strip and some wires for each node.

For now I just blink the builtin LEDs of the boards, more detail will follow once I built the actual hardware.

## Software stack

The software for rudelblinken is written in [toit](https://toitlang.org/), a high-level language designed for ESP32 programming. The devices are flashed with the [jaguar](https://github.com/toitlang/jaguar) firmware, which makes it possible to deploy toit programs over WiFi. Each device tries to connect to a hotspot named `rudelctrl` with the password `22po7gl334ai`. It is important that you use channel 6. You can start an AP with that configuration using `make start-ap`. You can also set your own WiFi and password when flashing the devices.

The devices communicate using the [ESP-NOW](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_now.html) protocol. ESP-NOW was choosen over WiFi, because WiFi is not connectionless. ESP-NOW was choosen over BLE, because it seems like the only way for connectionless communication. There are BLE advertisments but the ESP does not have an API to send a single advertisment, only to start sending in a given interval. ESP-NOW uses WiFi vendor-specific action frames. As it is using the WiFi hardware, it is limited to operating on the same channel as our WiFi connection. To receive messages from other devices they need to use the same channel. For rudelblinken this is channel 6. There are some limitations, when using ESP-NOW and WiFi at the same time.

For this reason toit does not allow ESP-NOW and WiFi to coexist. To fix this issue we use a [custom envelope](https://github.com/zebreus/toit-envelope-with-espnow) with a patched version of toit, that has removed the checks for coexistance and is patched so the ESP-NOW channel follows the WiFi channel and defaults to 6. So when you are flashing your esps with jaguar you need to use the custom envelope. The custom envelope also has a patch that lets any program access the name of the device. To built the patched firmware and flash a device with it run `make flash-DEVICENAME`.

Flashed devices will attempt to connect with the control AP and can be programmed via WiFi. Use `make run-all` to run the main program on all connected devices. Use `make install-all` to install the main program over multiple reboots on all devices. `make uninstall-all` to uninstall on all devices.

## Build instructions

You can find some basic instructions on how to build your own rudelblinken cat ears based on a ESP32-C3 supermini board at https://md.darmstadt.ccc.de/rudelblinken-mrmcd
