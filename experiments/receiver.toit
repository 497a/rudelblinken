import gpio
import gpio.pwm
import math
import esp32
import log
import core.utils
import net
import esp32.espnow
import device
import encoding.json
import encoding.ubjson
import system.firmware
import system.api.containers
import system.assets
import system
import encoding.tison
import ble
// import .communication

main:
  adapter := ble.Adapter
  central := adapter.central

  central.scan: | device/ble.RemoteScannedDevice |
    print "Found $device"