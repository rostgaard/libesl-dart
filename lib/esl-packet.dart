part of esl;

abstract class ContentType {
  static const String Text_Event_Plain = "text/event-plain";
  static const String Text_Event_JSON = "text/event-json";
  static const String Text_Event_Xml = "text/event-xml";

  static const String Auth_Request = "auth/request";

  static const String API_Reponse = "api/response";
  static const String Command_Reply = "command/reply";

  static final List<String> Event_Types = [Text_Event_JSON, Text_Event_Plain, Text_Event_Xml];
  static final List<String> Requests    = [Auth_Request];
  static final List<String> Responses   = [API_Reponse];
}

class Packet {

  static final String _variable_prefix = 'variable_';
  static int   count = 0;

  Map<String, String>     headers = null;
  String                  content = null;
  Map<String, String>  contentMap = null;
  Channel              _channel   = null;

  Packet() {
    this.headers = {};
    this.content = "";
  }

  String get contentType   => this.headers['Content-Type'];
  int    get contentLength => this.hasHeader('Content-Length')
                                ? int.parse(this.headers['Content-Length'])
                                : 0;

  bool get isEvent    => ContentType.Event_Types.contains(this.contentType);
  bool get isReply    => ContentType.Command_Reply == this.contentType;
  bool get isRequest  => ContentType.Requests.contains(this.contentType);
  bool get isResponse => ContentType.Responses.contains(this.contentType);
  bool get eventType  => ContentType.Event_Types.contains(this.contentType);

  Channel get channel {
    assert (this.isEvent);
    return this._channel == null ? this._channel = new Channel.fromPacket(this) : this._channel;
  }

  bool hasHeader(String key) {
    return this.headers.containsKey(key);
  }

  void addHeader(String key, String value) {
    this.headers[key] = value;
  }

  String get uniqueID  => this.contentAsMap['Unique-ID'];
  String get eventName => this.contentAsMap['Event-Name'];

  String get eventSubclass {
    if (this.contentAsMap.containsKey('Event-Subclass')) {
      return this.contentAsMap['Event-Subclass'];
    } else {
      return "";
    }
  }

  String field (String key) => this.contentAsMap[key];

  String variable (String key) {
    return this.contentAsMap['${_variable_prefix}key'];
  }

  Map<String, String> get contentAsMap {
    if (this.contentType == ContentType.Text_Event_JSON) {
      if (this.contentMap == null) {
        this.contentMap = JSON.decode(this.content);
      }
      return this.contentMap;
    } else {
      return {};
    }
  }
}
