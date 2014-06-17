part of esl;

abstract class ContentType {
  static const String Text_Event_Plain = "text/event-plain";
  static const String Text_Event_JSON = "text/event-json";
  static const String Text_Event_Xml = "text/event-xml";

  static const String Auth_Request = "auth/request";
  
  static final List<String> Event_Types = [Text_Event_JSON, Text_Event_Plain, Text_Event_Xml];

  static final List<String> Requests = [Auth_Request];
}

class Packet {

  static final String _variable_prefix = 'variable_';
  
  Map<String, String> headers = new Map<String, String>();
  String content = "";
  Map <String, String> contentMap = null;

  String get contentType   => this.headers['Content-Type'];
  int    get contentLength => this.hasHeader('Content-Length') 
                                ? int.parse(this.headers['Content-Length']) 
                                : 0;

  bool get isEvent   => ContentType.Event_Types.contains(this.contentType);
  bool get isRequest => ContentType.Requests.contains(this.contentType);
  bool get eventType => ContentType.Event_Types.contains(this.contentType);

  bool hasHeader(String key) {
    return this.headers.containsKey(key);
  }

  void addHeader(String key, String value) {
    this.headers[key] = value;
  }

  String get uniqueID {
    return this.contentAsMap['Unique-ID'];
  }
  
  
  String get eventName {
    return this.contentAsMap['Event-Name'];
  }

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
