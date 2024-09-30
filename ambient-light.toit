import gpio
import gpio.adc show Adc

adc := Adc (gpio.Pin 3)

ambient-brightness:
  raw_sensor_value := adc.get
  normalized_value := raw_sensor_value / 2.8969999999999997975
  return normalized-value
  