// Copyright (c) 2016, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl.util;

/// Utility function for handling the authentication process. Returns a
/// future that completes normally or throws an [AuthenticationFailure].
Future authHandler(Connection connection, String password) {
  final Logger _log = new Logger('esl.authHandler');

  Completer _authenticationProcess = new Completer();

  connection.requestStream.listen((Packet p) async {
    if (p.contentType == ContentType.authRequest) {
      _log.finest('Sending authentication');
      final Reply reply = await connection.authenticate(password);

      if (reply.status != Reply.ok) {
        final error = new AuthenticationFailure('Reply: ${reply.replyRaw}');
        _authenticationProcess.completeError(error);
      } else {
        _log.finest('Authentication succeeded');
        _authenticationProcess.complete();
      }
    }
  });

  return _authenticationProcess.future;
}
