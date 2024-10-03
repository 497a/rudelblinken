import gpio
import gpio.adc show Adc

adc := Adc (gpio.Pin 3)

ambient-brightness:
  raw_sensor_value := adc.get
  normalized_value := raw_sensor_value / 2.8969999999999997975
  return normalized-value

AMBIENT-BRIGHTNESS-DAMPENING ::= 0.9
mean-ambient-brightness /float := 0.0

ambient-light-task:
  while true:
    sleep --ms=100
    mean-ambient-brightness = AMBIENT-BRIGHTNESS-DAMPENING * mean-ambient-brightness + (1 - AMBIENT-BRIGHTNESS-DAMPENING)  * ambient-brightness
