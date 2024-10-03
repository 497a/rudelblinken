import .communication
import math
import core.utils

circular-mean samples/List minimum/int maximum/int:
  cycle-size ::= maximum - minimum
  normalized-samples ::= samples.map: (((it - minimum) % cycle-size) + cycle-size) % cycle-size
  angles ::= normalized-samples.map: (it* 3.1415 * 2.0) / cycle-size
  vectors := angles.map:
    [math.cos it, math.sin it]
  vector_sum := vectors.reduce --initial=[0.0001,0]: |acc it|
    [acc[0] + it[0], acc[1] + it[1]]
  print "$vector_sum[0]"
  print "$vector_sum[1]"
  average-offset-angle := math.atan2
    vector-sum[1] / (max 1 vectors.size)
    vector-sum[0] / (max 1 vectors.size)
  print "$average-offset-angle"
    
  average-offset := ((average-offset-angle * cycle-size ) / (3.1415 * 2.0)).to-int
  average-offset = minimum + ((cycle-size + average-offset) % cycle-size)
  return average-offset

class Cat:
  name /string := ?
  number-pulses := 0
  offset := 0
  last-pulse-time := 0

  constructor name/string:
    this.name = name
    
  add-pulse pulse/Pulse owner/Firefly:
    pulse-time := owner.time - pulse.ago
    offset = -1 * ((owner.last-pulse - pulse-time) % owner.preferred-pulse-length)
    if (offset < -1 * (owner.preferred-pulse-length / 2)):
        offset = owner.preferred-pulse-length + offset
    this.offset = offset
    this.last-pulse-time = pulse-time


class Firefly:
  name := ?
  preferred-pulse-length := ?
  // send_pulse := None
  pulse-progress := 0
  dampening := 0.9
  pulse-ttl := 10

  brightness := 0

  cats := {:}
  last-pulse := 0.0
  time := 0
  current-pulse-length /int := ?

  constructor name/string preferred-pulse-length/int:
    this.name = name
    this.preferred-pulse-length = preferred-pulse-length
    current-pulse-length = preferred-pulse-length
  
  tick delta/int:
    time += delta
    if (pulse-progress + delta) >= current-pulse-length:
      // How much time the pulse was ago
      pulse-ago := (pulse-progress + delta) % current-pulse-length
      my-pulse := Pulse
      my-pulse.sender = this.name
      my-pulse.ago = pulse-ago
      my-pulse.counter = 0
      send-pulse my-pulse
      last-pulse = time
      pulse-progress = pulse-progress - current-pulse-length + delta

      offsets := []
      cats.map: | key cat|
          if (this.time - cat.last-pulse-time <= this.preferred-pulse-length * this.pulse-ttl):
              offsets.add cat.offset
      global-offset := 0
      if offsets.size != 0:
          global_offset = circular-mean
            offsets
            (-1 * preferred-pulse-length) / 2
            preferred-pulse-length / 2
      print "###### Global offset $(global-offset)"
      current-pulse-length = (preferred-pulse-length + (global_offset * (1.0 - dampening))).to-int
    else:
      pulse-progress = (pulse-progress + delta) % current-pulse-length
    brightness = (pulse-progress.to-float / current-pulse-length.to-float) * 255.0
  
  receive-pulse pulse/Pulse:
    pulse_time := time - pulse.ago

    if (pulse.sender == name):
      // Should never happen in toit
      // return

    sender-cat := cats.get pulse.sender --init=:
      Cat pulse.sender 
    sender-cat.add-pulse pulse this