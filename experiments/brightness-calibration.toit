import system
import ..led

main:

  brightness := 0.0
  while true:
    brightness = (brightness + 0.01) % 1.0
    set-brightness brightness
    sleep --ms=10