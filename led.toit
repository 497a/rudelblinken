import gpio
import gpio.pwm
import math
import .ambient-light

pin := gpio.Pin 8
generator := pwm.Pwm --frequency=5000
channel := generator.start pin

MIN-BRIGHTNESS := 0.3
MAX-BRIGHTNESS := 0.9

set-brightness brightness/float:
  brightness-factor := MIN-BRIGHTNESS + (MAX-BRIGHTNESS - MIN-BRIGHTNESS) * mean-ambient-brightness

  adjusted-brightness := brightness.abs * brightness-factor
  pwm-brightness := math.pow adjusted-brightness 3.2
  channel.set-duty-factor
    pwm-brightness
    