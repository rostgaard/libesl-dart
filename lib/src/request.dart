// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// A request is a specialization of a [Packet] that is pushed from
/// FreeSWITCH whenever it needs the connecting party to act upon a
/// request. The first request a connection meets, is the 'auth' request.
class Request extends Packet {
  /// Construct a [Request] from a [Packet] object.
  Request.fromPacket(Packet packet) {
    headers = packet.headers;
    content = packet.content;
  }

  /// The content type of the Request.
  @deprecated
  String get type => contentType;
}
