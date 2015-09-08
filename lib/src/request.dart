// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

class Request extends Packet {

  String get type => this.contentType;

  Request.fromPacket(Packet packet) {
    this.headers = packet.headers;
    this.content = packet.content;
  }

}
