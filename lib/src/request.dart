part of esl;

class Request extends Packet {

  String get type => this.contentType;

  Request.fromPacket(Packet packet) {
    this.headers = packet.headers;
    this.content = packet.content;
  }

}
