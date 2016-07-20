// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// The esl library.
///
/// Utility library for communicating with a FreeSWTICH event socket.
library esl;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:esl/packet_transformer.dart';
import 'package:logging/logging.dart';

part 'src/channel.dart';
part 'src/channel_list.dart';
part 'src/connection.dart';
part 'src/event.dart';
part 'src/packet.dart';
part 'src/peer.dart';
part 'src/peer_list.dart';
part 'src/reply.dart';
part 'src/request.dart';
part 'src/response.dart';

/// General ESL exception. Useful for catching exceptions thrown by this
/// library.
class EslException implements Exception {}

/// Thrown when an authentication failure occurs within an authentication
/// handler. May be used be outside of the library.
class AuthenticationFailure implements EslException {
  /// The message carried in the exception.
  final String message;

  /// Default constructor. Takes in the optional [message] argument, which
  /// is empty, if omitted.
  const AuthenticationFailure([this.message = ""]);

  /// Returns a string representation of the object.
  @override
  String toString() => "AuthenticationFailure: $message";
}
