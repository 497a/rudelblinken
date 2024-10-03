import gpio
import gpio.pwm
import math

pin := gpio.Pin 8
generator := pwm.Pwm --frequency=5000
channel := generator.start pin

set-brightness brightness/float:
  channel.set-duty-factor
    math.pow brightness 4