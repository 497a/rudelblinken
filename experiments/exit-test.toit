// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the examples/LICENSE file.

import ble
import system

BATTERY-SERVICE ::= ble.BleUuid "180F"

main:
  print "hi"
  exit 0

  while true:
    print "ho"