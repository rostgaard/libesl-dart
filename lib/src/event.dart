// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

class Event extends Packet {
  static final String _variablePrefix = 'variable_';

  Channel _channel;

  String get uniqueID => contentAsMap['Unique-ID'];
  String get eventName => contentAsMap['Event-Name'];

  Event.fromPacket(Packet packet) {
    headers = packet.headers;
    content = packet.content;
  }

  String get eventSubclass {
    if (contentAsMap.containsKey('Event-Subclass')) {
      return contentAsMap['Event-Subclass'];
    } else {
      return "";
    }
  }

  /**
   * May return List or String.
   */
  dynamic variable(String key) {
    return contentAsMap['${_variablePrefix}key'];
  }

  Channel get channel =>
      _channel == null ? _channel = new Channel.fromPacket(this) : _channel;
}
