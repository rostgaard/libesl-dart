// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Various utility functions
library esl.util;

import 'dart:async';

import 'package:esl/esl.dart';
import 'package:esl/constants.dart';
import 'package:logging/logging.dart';

part 'src/authentication_handler.dart';

/// Converts a string buffer received from FreeSWITCH into a list of maps.
/// The string buffer is expected to be line-seperated, have the first line as
/// headers and every field seperated by a ','.
List<Map<String, String>> channelMapParse(String buffer) {
  List<Map<String, String>> retval = <Map<String, String>>[];

  bool header = true;

  List<String> keymap = <String>[];
  int offset = 0;
  buffer.split("\n").forEach((String line) {
    offset = 0;

    line.split(",").forEach((String item) {
      if (!header) {
        Map<String, String> currentMap = <String, String>{};
        if (offset == 0) {
          currentMap = <String, String>{};
          retval.add(currentMap);
        } else {
          currentMap = retval.last;
        }

        currentMap.addAll(<String, String>{keymap[offset]: item});
      } else {
        keymap.add(item);
      }
      offset++;
    });
    header = false;
  });

  return retval;
}
