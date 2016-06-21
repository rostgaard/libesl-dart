// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

abstract class ContentType {
  static const String textEventPlain = "text/event-plain";
  static const String textEventJson = "text/event-json";
  static const String textEventXml = "text/event-xml";
  static const String textDisconnectNotice = 'text/disconnect-notice';

  static const String authRequest = "auth/request";

  static const String apiReponse = "api/response";
  static const String commandReply = "command/reply";

  static final List<String> eventTypes = [
    textEventJson,
    textEventPlain,
    textEventXml
  ];

  static const List<String> requests = const [authRequest];
  static const List<String> responses = const [apiReponse];
  static const List<String> notices = const [textDisconnectNotice];
}

class Packet {
  static final Logger log = new Logger('esl.Packet');

  static int count = 0;

  Map<String, String> headers = null;
  String content = null;
  Map<String, dynamic> contentMap = null;

  Packet() {
    headers = {};
    content = "";
  }

  String get contentType => headers['Content-Type'];
  int get contentLength =>
      hasHeader('Content-Length') ? int.parse(headers['Content-Length']) : 0;

  bool get isEvent => ContentType.eventTypes.contains(contentType);
  bool get isReply => ContentType.commandReply == contentType;
  bool get isRequest => ContentType.requests.contains(contentType);
  bool get isResponse => ContentType.responses.contains(contentType);
  //TODO: Fix this
  bool get eventType => ContentType.eventTypes.contains(contentType);
  bool get isNotice => ContentType.notices.contains(contentType);

  bool hasHeader(String key) => headers.containsKey(key);

  void addHeader(String key, String value) {
    headers[key] = value;
  }

  String field(String key) => contentAsMap[key];

  Map<String, dynamic> get contentAsMap {
    if (contentType == ContentType.textEventJson) {
      if (contentMap == null) {
        try {
          contentMap = JSON.decode(content) as Map<String, dynamic>;
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
