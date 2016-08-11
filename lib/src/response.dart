// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

///Class representing a reponse received from the FreeSWITCH event socket.
class Response {
  /// Raw response body as string.
  final String content;

  /// Construct a new [Response] object from a packet body String.
  Response.fromPacket(Packet packet)
      : content = ASCII.decode(packet.payload, allowInvalid: true);

  /// Determines if the reply indicated a success.
  bool get isOk => status == _constant.CommandReply.ok;

  /// Determines if the reply indicated an error.
  bool get isError => status == _constant.CommandReply.ok;

  /// The status of the response. Can be either
  /// [_constant.CommandReply.ok], [_constant.CommandReply.error] or
  /// [_constant.CommandReply.unknown].
  String get status {
    String lastLine = content.split('\n').last;

    if (lastLine.startsWith(_constant.CommandReply.ok)) {
      return _constant.CommandReply.ok;
    } else if (lastLine.startsWith(_constant.CommandReply.error)) {
      return _constant.CommandReply.error;
    } else if (lastLine.startsWith(_constant.CommandReply.usage)) {
      return _constant.CommandReply.usage;
    } else {
      return _constant.CommandReply.unknown;
    }
  }

  /// Reponses may carry the UUID of a channel.
  String get channelUUID {
    String lastLine = content.split('\n').last;

    if (lastLine.startsWith(_constant.CommandReply.ok)) {
      return lastLine.replaceFirst(_constant.CommandReply.ok, '').trim();
    } else {
      throw new StateError('Response does not carry channel information. '
          'Raw body: $content');
    }
  }

  /// String representation of a Response for debug purposes or
  /// manual processing.
  @override
  String toString() => content;
}
