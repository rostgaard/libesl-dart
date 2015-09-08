// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

class Reply extends Packet {

  Reply.fromPacket(Packet packet) {
    this.headers = packet.headers;
  }

  static const String OK = Response.OK;
  static const String ERROR = Response.ERROR;
  static const String UNKNOWN = Response.UNKNOWN;

  String get replyRaw => this.headers['Reply-Text'];

  String get status {
    if (this.replyRaw.startsWith(OK)) {
      return OK;
    } else if (this.replyRaw.startsWith(ERROR)) {
      return ERROR;
    } else {
      return UNKNOWN;
    }
  }

}
