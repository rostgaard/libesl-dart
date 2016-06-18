// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

class Reply extends Packet {
  Reply.fromPacket(Packet packet) {
    headers = packet.headers;
  }

  @deprecated
  static const String OK = ok;
  @deprecated
  static const String ERROR = error;
  @deprecated
  static const String UNKNOWN = unknown;

  static const String ok = Response.ok;
  static const String error = Response.error;
  static const String unknown = Response.unknown;

  String get replyRaw => headers['Reply-Text'];

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
