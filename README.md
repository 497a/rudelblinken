# rudelblinken

Synced blinking catears

## Notes

Less of a Readme, more a unstructured braindump

## Hardware

rudelblinken is based on ESP32-C3 supermicro boards. Each device controls a single color LED strip. This should keep the hardware setup quite, simple requiring only a esp board, a mosfet, an LED strip and some wires for each node.

For now I just blink the builtin LEDs of the boards, more detail will follow once I built the actual hardware.

## Software

The software for rudelblinken is written in [toit](https://toitlang.org/), a high-level language designed for ESP32 programming. The devices are flashed with the [jaguar](https://github.com/toitlang/jaguar) firmware, which makes it possible to deploy toit programs over WiFi. Each device tries to connect to a hotspot name `rudelctrl` with the password `22po7gl334ai`. It is important that you use channel 6. You can start an AP with that configuration using `make start-ap`. You can also set your own WiFi and password when flashing the devices.

The devices communicate using the [ESP-NOW](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/network/esp_now.html) protocol. ESP-NOW was choosen over WiFi, because WiFi is not connectionless. ESP-NOW was choosen over BLE, because it seems like the only way for connectionless communication there are advertisments, but the ESP does not have an API to send a single advertisment. ESP-NOW uses WiFi vendor-specific action frames. As it is using the WiFi hardware, it is limited to operating on the same channel as our WiFi connection. There are some limitations, when using ESP-NOW and WiFi at the same time.

For this reason toit does not allow ESP-NOW and WiFi to coexist. To fix this issue we use a custom envelope with a patched version of toit, that has removed the checks for coexistance and is patched so the ESP-NOW channel follows the WiFi channel and defaults to 6. So when you are flashing your esps with jaguar you need to use the custom envelope. The custom envelope also has a patch that lets any program access the name of the device. I will add instructions on how to flash it and a prebuilt version in the future.
