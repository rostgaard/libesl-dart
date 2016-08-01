// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Convenience library with pre-entered ESL constants.
library esl.constants;

import 'package:esl/esl.dart';

/// Packet content types.
abstract class ContentType {
  /// Content type `text/event-plain`.
  static const String textEventPlain = "text/event-plain";

  /// Content type `text/event-json`.
  static const String textEventJson = "text/event-json";

  /// Content type `text/event-xml`.
  static const String textEventXml = "text/event-xml";

  /// Content type `text/disconnect-notice`.
  static const String textDisconnectNotice = 'text/disconnect-notice';

  /// Content type `auth/request`.
  static const String authRequest = "auth/request";

  /// Content type `api/response`.
  static const String apiReponse = "api/response";

  /// Content type `command/reply`.
  static const String commandReply = "command/reply";

  /// List of content types that qualify as events. Useful for detmining if
  /// a [Packet] is an instance of an event.
  static const List<String> eventTypes = const [
    textEventJson,
    textEventPlain,
    textEventXml
  ];

  /// List of content types that qualify as requests. Useful for detmining
  /// if a [Packet] is an instance of an request.
  static const List<String> requests = const [authRequest];

  /// List of content types that qualify as response. Useful for detmining
  /// if a [Packet] is an instance of an response.
  static const List<String> responses = const [apiReponse];

  /// List of content types that qualify as notices. Useful for detmining
  /// if a [Packet] is an instance of an notice.
  static const List<String> notices = const [textDisconnectNotice];
}
