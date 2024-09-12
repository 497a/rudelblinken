# rudelblinken

Synced blinking catears

## Notes

Less of a Readme, more a unstructured braindump

## Hardware

rudelblinken is based on ESP32-C3 supermicro boards. Each device controls a single color LED strip. This should keep the hardware setup quite, simple requiring only a esp board, a mosfet, an LED strip and some wires for each node.

For now I just blink the builtin LEDs of the boards, more detail will follow once I built the actual hardware.

## Software

The software for rudelblinken is written in [toit](https://toitlang.org/), a high-level language designed for ESP32 programming. The devices are flashed with the [jaguar](https://github.com/toitlang/jaguar) firmware, which makes it possible to deploy toit programs over WiFi. Each device tries to connect to a hotspot name `rudelctrl` with the password `22po7gl334ai`. You can start an AP with that configuration using `make start-ap`. You can also set your own WiFi and password when flashing the devices.
