// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// A request is a specialization of a [Packet] that is pushed from
/// FreeSWITCH whenever it needs the connecting party to act upon a
/// request. The first request a connection meets, is the 'auth' request.
abstract class Notice {
  /// Construct a [Notice] from a [Packet] object.
  factory Notice.fromPacket(Packet packet) {
    if (packet.contentType == _constant.ContentType.textDisconnectNotice) {
      return new DisconnectNotice();
    } else {
      throw new StateError('Invalid content type for '
          'request: ${packet.contentType}');
    }
  }
}

/// Authentication request class.
class DisconnectNotice implements Notice {}
