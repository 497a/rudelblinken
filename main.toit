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
import .sync
// import .communication

INTERVAL ::= Duration --us=100

TARGET-SPEED ::= 1000
// Length of a subcycle in us
speed := TARGET-SPEED
CYCLE-LENGTH ::= 5000
// How many cycle steps were taken
cycle-progress := 0
// How many us were already spend in this substep
unprocessed-delta := 0

PMK ::= espnow.Key.from-string "mustbe16bytesaaa"

device-name:
  config := {:}
  assets.decode.get "config" --if-present=: | encoded |
      catch: config = tison.decode encoded
  return config.get "name"

main args:
  print "Hey, my name is $device-name"

  service := espnow.Service.station --key=PMK --channel=6
  service.add-peer espnow.BROADCAST-ADDRESS
  task:: receiver-task service
  task:: clock-task service

class Flash:
    sender /string := ""
    ago /int := 0
    preferred /int := 0
    received-at /int := 0

    stringify:
      return json.stringify {
        "sender": sender,
        "ago": ago,
        "received-at": received-at
      }

flashes := []

receiver-task service/espnow.Service:
  count := 0
  while true:
    datagram := service.receive
    received-data := json.decode datagram.data
    flash := Flash
    flash.ago = received-data["ago"].to-int
    flash.preferred = received-data["preferred"].to-int
    flash.sender = received-data["sender"]
    flash.received-at = Time.monotonic-us --since-wakeup=true
    // flashes.add flash
    receive-ping
      flash.sender
      flash.received-at.to-int - flash.ago.to-int
      flash.preferred
    print "Receive datagram from \"$datagram.address\", data: \"$flash\""
  

profiler := Profiler



clock-task service/espnow.Service:
  pin := gpio.Pin 8
  generator := pwm.Pwm --frequency=5000
  channel := generator.start pin
  last-time := Time.monotonic-us --since-wakeup=true
  delta-count := 0
  delta-sum := 0
  while true:
    // Profiler.start

    time := Time.monotonic-us --since-wakeup=true
    time-delta := unprocessed-delta + time - last-time
    last-time = time
    channel.set-duty-factor cycle-progress/(CYCLE-LENGTH.to-float)
    // print "Cycle: $(%05d cycle) Speed: $(%05d speed)"

    remaining-delta-before-overflow := (CYCLE-LENGTH - cycle-progress) * speed + (speed - unprocessed-delta);
    time-delta-before-overflow := utils.min time-delta remaining-delta-before-overflow
    time-delta-after-overflow := time-delta - time-delta-before-overflow
    cycle-progress = cycle-progress + (time-delta-before-overflow / speed)
    unprocessed-delta = time-delta-before-overflow % speed

    // Profiler.stop
    if cycle-progress >= CYCLE-LENGTH:
      cycle-progress %= CYCLE-LENGTH
      print "Average adelta during last cycle: $(%5d delta-sum / delta-count)us"
      speed = TARGET-SPEED
      service.send
          json.encode {
            "sender": device-name,
            "ago": time-delta-after-overflow.to-int,
            "preferred": CYCLE-LENGTH * TARGET-SPEED
          }
          --address=espnow.BROADCAST-ADDRESS
      own-pulse-timestamp := time - time-delta-after-overflow
      own-offset := own-pulse-timestamp % (CYCLE-LENGTH * TARGET-SPEED)

      preferred := PeerInformation
      preferred.estimated-shift = 0
      preferred.estimated-duration = (CYCLE-LENGTH * TARGET-SPEED)
      last := PeerInformation
      last.estimated-shift = 0
      last.estimated-duration = speed * CYCLE-LENGTH

      sleep INTERVAL
      next-duration := predict-next-duration preferred last own-pulse-timestamp.to-int
      // remaining-next-duration := max
      //   1
      //   next-duration - time-delta-after-overflow
      // TODO: Adjust this for remaining-next-duration and compensate for lost time
      // speed = speed /2 + ((next-duration / CYCLE-LENGTH)/2)
      speed = next-duration / CYCLE-LENGTH
      
      delta-count = 0
      delta-sum = 0
    
    cycle-progress = (cycle-progress + (time-delta-after-overflow / speed)) % CYCLE-LENGTH
    unprocessed-delta += time-delta-after-overflow % speed

    sleep INTERVAL
    delta-count += 1
    delta-sum += time-delta
    // log.info "Delta: $(%5d time-delta) cycle-progress: $(%5d cycle-progress) unprocessed-delta: $(%5d unprocessed-delta)"