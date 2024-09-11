import gpio
import gpio.pwm
import math
import esp32
import log

INTERVAL ::= Duration --us=100

TARGET-SPEED ::= 100
// Length of a subcycle in us
speed := TARGET-SPEED
CYCLE-LENGTH ::= 5000
// How many cycle steps were taken
cycle-progress := 0
// How many us were already spend in this substep
unprocessed-delta := 0

main:
  log.set_default (log.default.with_level log.ERROR-LEVEL)
  // task:: printer-task
  task:: clock-task

printer-task:
  while true:
    // print "Cycle: $(%05d cycle) Speed: $(%05d speed)"
    sleep (Duration --us=100)

profiler := Profiler

clock-task:
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
    cycle-progress = cycle-progress + (time-delta / speed)
    // Profiler.stop
    if cycle-progress >= CYCLE-LENGTH:
      cycle-progress %= CYCLE-LENGTH
      print "Average delta during last cycle: $(%5d delta-sum / delta-count)us"
      speed = TARGET-SPEED
      delta-count = 0
      delta-sum = 0
      
    unprocessed-delta = time-delta % speed

    sleep INTERVAL
    delta-count += 1
    delta-sum += time-delta
    // log.info "Delta: $(%5d time-delta) cycle-progress: $(%5d cycle-progress) unprocessed-delta: $(%5d unprocessed-delta)"