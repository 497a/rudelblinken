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
  
  encode:
    return json.encode {
      "sender": this.sender,
      "ago": this.ago,
      "counter": this.counter,
      "pulsev1": 1
    }
  
  decode received-data/Map:
    if received-data["pulsev1"] != 1:
      return false
    this.ago = received-data["ago"].to-int
    this.counter = received-data["counter"].to-int
    this.sender = received-data["sender"]
    return true

send-pulse pulse/Pulse:
  service.send
    pulse.encode
    --address=espnow.BROADCAST-ADDRESS

receiver-task on-pulse/Lambda:
  count := 0
  while true:
    datagram := service.receive
    received-data := json.decode datagram.data
    pulse := Pulse
    decoded-successfully := pulse.decode received-data

    if decoded-successfully:
      on-pulse.call pulse
    
    print "Receive datagram from \"$datagram.address\", data: \"$pulse\""

init-communication:
  service = espnow.Service.station --key=PMK --channel=6
  service.add-peer espnow.BROADCAST-ADDRESS