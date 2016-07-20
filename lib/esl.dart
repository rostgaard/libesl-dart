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

class EslException implements Exception {}

class AuthenticationFailure implements EslException {
  final String message;
  const AuthenticationFailure([this.message = ""]);

  @override
  String toString() => "AuthenticationFailure: $message";
}
