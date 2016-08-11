// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Model class of an ESL packet.
class Packet {
  static final Logger _log = new Logger('esl.Packet');

  /// The headers of the packet.
  final Map<String, String> headers;

  /// The raw payload of the packet in bytes.
  final List<int> payload;

  /// Create a new empty packet.
  const Packet(this.headers, this.payload);

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

  /// Returns true if the [Packet] headers contains field [key].
  bool hasHeader(String key) => headers.containsKey(key);
}
