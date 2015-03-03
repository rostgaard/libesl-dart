// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// The esl library.
///
/// Utility library for communicating with a FreeSWTICH event socket.
library esl;

// TODO: Export any libraries intended for clients of this package.

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:logging/logging.dart';

part 'src/channel.dart';
part 'src/channel_list.dart';
part 'src/connection.dart';
part 'src/event.dart';
part 'src/packet.dart';
part 'src/packet_transformer.dart';
part 'src/peer.dart';
part 'src/peer_list.dart';
part 'src/reply.dart';
part 'src/response.dart';

const String libraryName = 'ESL';
