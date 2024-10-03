import system
import ..led
import math

main:

  brightness := 0.0
  while true:
    brightness = (brightness + 0.01)
    set-brightness
      (1 + (math.sin brightness))/2.0
    sleep --ms=5