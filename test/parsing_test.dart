// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.test;

import 'package:test/test.dart';
import 'package:esl/esl.dart' as esl;

part 'peer_list.dart';
part 'response.dart';

void main() {
  group('Parsing', () {
    test('PeerList.fromMultilineBuffer', parsePeerBuffer);

    test('Response (detects -USAGE)', Response.detectsUsage);
    test('Response (detects -ERR)', Response.detectsError);
    test('Response (detects +OK)', Response.detectsOK);
  });
}
