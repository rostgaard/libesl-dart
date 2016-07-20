// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.test;

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:esl/esl.dart' as esl;
import 'package:esl/util.dart' as esl;

import 'src/dummy_esl.dart';

part 'peer_list.dart';
part 'response.dart';

/// Test group
void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  group('AuthenticationHandler', () {
    test('correct password', _correctPassword);
    test('wrong password', _wrongPassword);
  });
}

Future _correctPassword() async {
  final String password = 'dummy';
  final esl.Connection connection = new esl.Connection();
  final DummyEsl dummyEsl =
      new DummyEsl(await ServerSocket.bind('127.0.0.1', 18021), password);

  await connection.connect('127.0.0.1', 18021);

  Future authentication = esl.authHandler(connection, password);

  await authentication;
  await connection.disconnect();
  await dummyEsl.close();
}

Future _wrongPassword() async {
  final String password = 'dummy';
  final esl.Connection connection = new esl.Connection();
  final DummyEsl dummyEsl =
      new DummyEsl(await ServerSocket.bind('127.0.0.1', 18021), password);

  await connection.connect('127.0.0.1', 18021);

  Future authentication = esl.authHandler(connection, password + 'wrong');

  try {
    await authentication;
  } on esl.AuthenticationFailure {
    // Expected result.
  }

  await connection.disconnect();
  await dummyEsl.close();
}
