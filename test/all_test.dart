// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.test;

import 'dart:io' as IO;
import 'dart:async';
import 'package:test/test.dart';
import 'package:esl/esl.dart' as ESL;

part 'packet_transformer.dart';
part 'peer_list.dart';
part 'response.dart';

main() {
  group('Parsing', () {
    test('PeerList.fromMultilineBuffer', parsePeerBuffer);
    test('PacketTransformer (text files)', () {
      expect(packetTransformer(), completion(isNotNull));
    });

    test('Response (detects -USAGE)', Response.detectsUsage);
    test('Response (detects -ERR)', Response.detectsError);
    test('Response (detects +OK)', Response.detectsOK);
  });
}
