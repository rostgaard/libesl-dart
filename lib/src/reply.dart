// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Reply packet class. Specialization of [Packet] class.
class Reply {
  /// Creates new [Reply] object from a general [Packet] object.
  Reply.fromPacket(Packet packet) : replyRaw = packet.headers['Reply-Text'];

  /// Returns the reply body, without parsing it.
  final String replyRaw;

  /// Determines if the reply indicated a success.
  bool get isOk => status == _constant.CommandReply.ok;

  /// Determines if the reply indicated an error.
  bool get isError => status == _constant.CommandReply.ok;

  /// Parses and retrieves the response status as either
  /// [_constant.CommandReply.ok], [_constant.CommandReply.error] or
  /// [_constant.CommandReply.unknown].
  String get status {
    if (replyRaw.startsWith(_constant.CommandReply.ok)) {
      return _constant.CommandReply.ok;
    } else if (replyRaw.startsWith(_constant.CommandReply.error)) {
      return _constant.CommandReply.error;
    } else {
      return _constant.CommandReply.unknown;
    }
  }
}
