part of esl;

class Event extends Packet {

  static final String _variable_prefix = 'variable_';

  String _name = null;
  Channel _channel = null;

  String get uniqueID => this.contentAsMap['Unique-ID'];
  String get eventName => this.contentAsMap['Event-Name'];

  Event.fromPacket(Packet packet) {
    this.headers = packet.headers;
    this.content = packet.content;
  }

  String get eventSubclass {
    if (this.contentAsMap.containsKey('Event-Subclass')) {
      return this.contentAsMap['Event-Subclass'];
    } else {
      return "";
    }
  }

  /**
   * May return List or String.
   */
  dynamic variable(String key) {
    return this.contentAsMap['${_variable_prefix}key'];
  }

  Channel get channel => this._channel == null ? this._channel =
      new Channel.fromPacket(this) : this._channel;

}
