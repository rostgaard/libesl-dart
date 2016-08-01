// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Reply packet class. Specialization of [Packet] class.
class Reply extends Packet {
  /// Creates new [Reply] object from a general [Packet] object.
  Reply.fromPacket(Packet packet) {
    headers = packet.headers;
  }

  /// Command reply `+OK` constant.
  static const String ok = Response.ok;

  /// Command reply `+ERROR` constant.
  static const String error = Response.error;

  /// Command reply for all other values other than [ok] and [error].
  static const String unknown = Response.unknown;

  /// Returns the reply body, without parsing it.
  String get replyRaw => headers['Reply-Text'];

  /// Parses and retrieves the response status as either [ok], [error] or
  /// [unknown].
  String get status {
    if (replyRaw.startsWith(ok)) {
      return ok;
    } else if (replyRaw.startsWith(error)) {
      return error;
    } else {
      return unknown;
    }
  }
}
