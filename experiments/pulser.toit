// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the examples/LICENSE file.

import ble
import system

BATTERY-SERVICE ::= ble.BleUuid "180F"

class BlePulser:
  adapter := ble.Adapter
  time := Time.monotonic-us --since-wakeup=true

  sendPulse:
    peripheral := adapter.peripheral

    data := ble.AdvertisementData
      --name="Martin"
      --service-classes=[BATTERY-SERVICE]
      --manufacturer-data=#[0xff, 0xff, 0x74, 0x6f, 0x69, 0x74]

    peripheral.start-advertise data 
      --interval=Duration --ms=200
    sleep --ms=1
    peripheral.stop-advertise
  
  start-scan [block]:
    central := adapter.central




    while true:
      central.scan --duration=(Duration --ms=100) : | device/ble.RemoteScannedDevice |
          if device.data.manufacturer-data == #[0xff, 0xff, 0x74, 0x6f, 0x69, 0x74]:
            newTime := Time.monotonic-us --since-wakeup=true
            delta := newTime - time
            time = newTime
            print "Delta: $delta"
        
        
        
    
main:
  pulser := BlePulser
  print "hi"
  exit 0

  task:: pulser.start-scan:
    print "hi"

  while true:
    pulser.sendPulse
    sleep --ms=250