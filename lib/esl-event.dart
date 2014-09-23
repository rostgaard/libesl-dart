part of esl;

class Event extends Packet {
  String  _name    = null;
  Channel _channel = null;

  Event.fromPacket (Packet packet) {
    this.headers = packet.headers;
    this.content = packet.content;
  }

}
