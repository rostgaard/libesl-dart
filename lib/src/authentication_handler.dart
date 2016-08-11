// Copyright (c) 2016, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl.util;

/// Utility function for handling the authentication process. Returns a
/// future that completes normally or throws an [AuthenticationFailure].
Future<Null> authHandler(Connection connection, String password) {
  final Logger _log = new Logger('esl.authHandler');

  Completer<Null> _authenticationProcess = new Completer<Null>();

  connection.requestStream.listen((Request r) async {
    if (r is AuthRequest) {
      _log.finest('Sending authentication');
      final Reply reply = await connection.authenticate(password);

      if (reply.status != CommandReply.ok) {
        final AuthenticationFailure error =
            new AuthenticationFailure('Reply: ${reply.replyRaw}');
        _authenticationProcess.completeError(error);
      } else {
        _log.finest('Authentication succeeded');
        _authenticationProcess.complete();
      }
    }
  });

  return _authenticationProcess.future;
}
