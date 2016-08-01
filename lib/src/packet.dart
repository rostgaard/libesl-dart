// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Model class of an ESL packet.
class Packet {
  static final Logger _log = new Logger('esl.Packet');

  /// The headers of the packet.
  Map<String, String> headers;

  /// The raw (stringified) payload of the packet.
  String content;

  final Map<String, dynamic> _contentMap = {};

  /// Create a new empty packet.
  Packet() {
    headers = {};
    content = "";
  }

  /// The content type of the packet. Looks up the `Content-Type` field
  /// of the header.
  String get contentType => headers['Content-Type'];

  /// The content type of the packet. Looks up the `Content-Length` field
  /// of the header. If no header is present, returned value is `0`.
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
      : throw new StateError('Packet is not an event, but $contentType');

  /// Returns true if the [Packet] headers contains field [key].
  bool hasHeader(String key) => headers.containsKey(key);

  /// Adds a header to the [Packet].
  void addHeader(String key, String value) {
    headers[key] = value;
  }

  /// The value of content field identified at key [key].
  String field(String key) => contentAsMap[key];

  /// The content of the [Packet] as a map.
  Map<String, dynamic> get contentAsMap {
    if (contentType == _constant.ContentType.textEventJson) {
      if (_contentMap.isEmpty) {
        try {
          _contentMap.addAll(JSON.decode(content) as Map<String, dynamic>);
        } catch (error, stacktrace) {
          _log.severe(
              'Failed to parse following packet content as JSON '
              'string:\n$content',
              stacktrace);
        }
      }
      return _contentMap;
    } else {
      throw new UnsupportedError('Supported event formats are currently '
          'limited to${EventFormat.supportedFormats}');
    }
  }
}
