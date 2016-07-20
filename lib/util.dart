// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Various utility functions
library esl.util;

import 'dart:async';

import 'package:esl/esl.dart';
import 'package:logging/logging.dart';

part 'src/authentication_handler.dart';

/// Converts a string buffer received from FreeSWITCH into a list of maps.
/// The string buffer is expected to be line-seperated, have the first line as
/// headers and every field seperated by a ','.
List<Map> channelMapParse(String buffer) {
  List<Map> retval = [];

  bool header = true;

  List keymap = [];
  int offset = 0;
  buffer.split("\n").forEach((String line) {
    offset = 0;

    line.split(",").forEach((String item) {
      if (!header) {
        Map currentMap = {};
        if (offset == 0) {
          currentMap = {};
          retval.add(currentMap);
        } else {
          currentMap = retval.last;
        }

        currentMap.addAll({keymap[offset]: item});
      } else {
        keymap.add(item);
      }
      offset++;
    });
    header = false;
  });

  return retval;
}
