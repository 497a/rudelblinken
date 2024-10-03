import esp32.espnow
import encoding.json
import encoding.ubjson

PMK ::= espnow.Key.from-string "mustbe16bytesaaa"

service/espnow.Service := ?

class Pulse:
  // Unique name of the sender
  sender /string := ""
  // The sender usually sends the pulse a few millis after it actually pulsed
  // This field specifies how old the pulse was when it was send
  ago /int := 0
  counter /int := 0

  stringify:
    return json.stringify {
      "sender": sender,
      "ago": ago,
      "counter": counter
    }


send-pulse pulse/Pulse:
  service.send
    json.encode {
      "sender": pulse.sender,
      "ago": pulse.ago,
      "counter": pulse.counter
    }
    --address=espnow.BROADCAST-ADDRESS


receiver-task on-pulse/Lambda:
  count := 0
  while true:
    datagram := service.receive
    received-data := json.decode datagram.data
    pulse := Pulse
    pulse.ago = received-data["ago"].to-int
    pulse.counter = received-data["counter"].to-int
    pulse.sender = received-data["sender"]

    on-pulse.call pulse
    
    print "Receive datagram from \"$datagram.address\", data: \"$pulse\""

init-communication:
  service = espnow.Service.station --key=PMK --channel=6
  service.add-peer espnow.BROADCAST-ADDRESS