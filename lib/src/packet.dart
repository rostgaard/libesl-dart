// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Model class of an ESL packet.
class Packet {
  static final Logger log = new Logger('esl.Packet');

  static int count = 0;

  Map<String, String> headers;
  String content;
  Map<String, dynamic> contentMap = {};

  Packet() {
    headers = {};
    content = "";
  }

  String get contentType => headers['Content-Type'];
  int get contentLength =>
      hasHeader('Content-Length') ? int.parse(headers['Content-Length']) : 0;

  /// Determines if the [Packet] is an event and may be cast to an [Event].
  bool get isEvent => _constant.ContentType.eventTypes.contains(contentType);

  /// Determines if the [Packet] is a reply and may be cast to a [Reply].
  bool get isReply => _constant.ContentType.commandReply == contentType;

  /// Determines if the [Packet] is a request and may be cast to a
  /// [Request].
  bool get isRequest => _constant.ContentType.requests.contains(contentType);

  /// Determines if the [Packet] is a response and may be cast to a
  /// [Response].
  bool get isResponse => _constant.ContentType.responses.contains(contentType);

  /// Determines if the [Packet] is a notice.
  bool get isNotice => _constant.ContentType.notices.contains(contentType);

  /// The name of the event. If the [Packet] is not an event, it will throw
  /// a [StateError].
  @deprecated
  String get eventType => isEvent
      ? contentAsMap['Event-Name']
      : throw new StateError('Packet is not an event, but ${contentType}');

  bool get isNotice => ContentType.notices.contains(contentType);

  bool hasHeader(String key) => headers.containsKey(key);

  void addHeader(String key, String value) {
    headers[key] = value;
  }

  String field(String key) => contentAsMap[key];

  Map<String, dynamic> get contentAsMap {
    if (contentType == _constant.ContentType.textEventJson) {
      if (_contentMap.isEmpty) {
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
