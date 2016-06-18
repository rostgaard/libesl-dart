// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 * Class representing a reponse received from the FreeSWTICH event socket.
 */
class Response {
  /// String constants that map to responses.
  @deprecated
  static const String OK = '+OK';
  @deprecated
  static const String ERROR = '-ERR';
  @deprecated
  static const String USAGE = '-USAGE';
  @deprecated
  static const String UNKNOWN = '';

  static const String ok = '+OK';
  static const String error = '-ERR';
  static const String usage = '-USAGE';
  static const String unknown = '';

  final String rawBody;

  Response.fromPacketBody(String this.rawBody);

  /**
   * The status of the response. Can be either [ok], [error] or [unknown].
   */
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

  /**
   * Reponses may carry the UUID of a channel.
   */
  String get channelUUID {
    String lastLine = rawBody.split('\n').last;

    if (lastLine.startsWith(ok)) {
      return lastLine.substring(ok.length, lastLine.length).trim();
    } else {
      throw new StateError('Response does not carry channel information. '
          'Raw body: ${rawBody}');
    }
  }

  /**
   * String representation of a Response for debug purposes or
   * manual processing.
   */
  @override
  String toString() {
    return rawBody;
  }
}
