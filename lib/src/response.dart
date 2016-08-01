// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

///Class representing a reponse received from the FreeSWITCH event socket.
class Response {
  /// Command response `+OK` constant.
  static const String ok = '+OK';

  /// Command response `-ERR` constant.
  static const String error = '-ERR';

  /// Command response `-USAGE` constant.
  static const String usage = '-USAGE';

  /// Command reply for all other values.
  static const String unknown = '';

  /// Raw response body as string.
  final String rawBody;

  /// Construct a new [Response] object from a packet body String.
  Response.fromPacketBody(this.rawBody);

  /// The status of the response. Can be either [ok], [error], [usage]
  /// or [unknown].
  String get status {
    String lastLine = rawBody.split('\n').last;

    if (lastLine.startsWith(ok)) {
      return ok;
    } else if (lastLine.startsWith(error)) {
      return error;
    } else if (lastLine.startsWith(usage)) {
      return usage;
    } else {
      return unknown;
    }
  }

  /// Reponses may carry the UUID of a channel.
  String get channelUUID {
    String lastLine = rawBody.split('\n').last;

    if (lastLine.startsWith(ok)) {
      return lastLine.substring(ok.length, lastLine.length).trim();
    } else {
      throw new StateError('Response does not carry channel information. '
          'Raw body: $rawBody');
    }
  }

  /// String representation of a Response for debug purposes or
  ///  manual processing.
  @override
  String toString() {
    return rawBody;
  }
}
