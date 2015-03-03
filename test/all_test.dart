// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.test;

import 'dart:io' as IO;
import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:esl/esl.dart' as ESL;
import 'package:junitconfiguration/junitconfiguration.dart';

part 'packet_transformer.dart';


main() {
  JUnitConfiguration.install();

  group('Parsing', () {
    test('PacketTransformer (text files)', () {
      expect(packet_transformer(), completion(isNotNull));
    });
  });
}
