// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the examples/LICENSE file.

import ble

BATTERY-SERVICE ::= ble.BleUuid "180F"

main:
  adapter := ble.Adapter
  peripheral := adapter.peripheral

  data := ble.AdvertisementData
      --name="Toit device"
      --service-classes=[BATTERY-SERVICE]
      --manufacturer-data=#[0xFF, 0xFF, 't', 'o', 'i', 't']

  while true:
    peripheral.start-advertise data 
      --interval=Duration --ms=200
    sleep --ms=200000
    peripheral.stop-advertise