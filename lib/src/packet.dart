// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

abstract class ContentType {
  static const String Text_Event_Plain = "text/event-plain";
  static const String Text_Event_JSON = "text/event-json";
  static const String Text_Event_Xml = "text/event-xml";
  static const String Text_Disconnect_Notice = 'text/disconnect-notice';

  static const String Auth_Request = "auth/request";

  static const String API_Reponse = "api/response";
  static const String Command_Reply = "command/reply";

  static final List<String> Event_Types = [
    Text_Event_JSON,
    Text_Event_Plain,
    Text_Event_Xml
  ];
  static const List<String> Requests = const [Auth_Request];
  static const List<String> Responses = const [API_Reponse];
  static const List<String> Notices = const [Text_Disconnect_Notice];
}

class Packet {
  static final Logger log = new Logger('${libraryName}.Packet');

  static int count = 0;

  Map<String, String> headers = null;
  String content = null;
  Map<String, String> contentMap = null;

  Packet() {
    headers = {};
    content = "";
  }

  String get contentType => headers['Content-Type'];
  int get contentLength =>
      hasHeader('Content-Length') ? int.parse(headers['Content-Length']) : 0;

  bool get isEvent => ContentType.Event_Types.contains(contentType);
  bool get isReply => ContentType.Command_Reply == contentType;
  bool get isRequest => ContentType.Requests.contains(contentType);
  bool get isResponse => ContentType.Responses.contains(contentType);
  bool get eventType => ContentType.Event_Types.contains(contentType);
  bool get isNotice => ContentType.Notices.contains(contentType);

  bool hasHeader(String key) => headers.containsKey(key);

  void addHeader(String key, String value) {
    headers[key] = value;
  }

  String field(String key) => contentAsMap[key];

  Map<String, String> get contentAsMap {
    if (contentType == ContentType.Text_Event_JSON) {
      if (contentMap == null) {
        try {
          contentMap = JSON.decode(content);
        } catch (error, stacktrace) {
          log.severe(
              'Failed to parse following packet content as JSON '
              'string:\n${content}',
              stacktrace);
        }
      }
      return contentMap;
    } else {
      throw new UnsupportedError('Supported event formats are currently '
          'limited to${EventFormat.supportedFormats}');
    }
  }
}
