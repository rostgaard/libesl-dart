// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// A request is a specialization of a [Packet] that is pushed from
/// FreeSWITCH whenever it needs the connecting party to act upon a
/// request. The first request a connection meets, is the 'auth' request.
abstract class Request {
  /// Construct a [Request] from a [Packet] object.
  factory Request.fromPacket(Packet packet) {
    if (packet.contentType == _constant.ContentType.authRequest) {
      return new AuthRequest();
    } else {
      throw new StateError('Invalid content type for '
          'request: ${packet.contentType}');
    }
  }
}

/// Authentication request class.
class AuthRequest implements Request {}
