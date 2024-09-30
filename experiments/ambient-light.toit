import gpio
import gpio.adc show Adc

main:
  adc := Adc (gpio.Pin 3)
  
  while true:
    print adc.get
    sleep --ms=100
  