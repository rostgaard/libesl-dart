// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Event subclass. Provides additional (mostly for convenience) accessor
/// methods.
class Event extends Packet {
  static final String _variablePrefix = 'variable_';

  Channel _channel;

  /// Create a new [Event] from a [Packet] object.
  Event.fromPacket(Packet packet) {
    headers = packet.headers;
    content = packet.content;
  }

  /// Returns the unique ID (packet field `Unique-ID`) of the channel.
  String get uniqueID => contentAsMap['Unique-ID'];

  /// Returns name (packet field `Event-Name`) of the event.
  String get eventName => contentAsMap['Event-Name'];

  /// Returns event subclass (packet field `Event-Subclass`) of the event.
  String get eventSubclass {
    if (contentAsMap.containsKey('Event-Subclass')) {
      return contentAsMap['Event-Subclass'];
    } else {
      return "";
    }
  }

  /// May return List or String.
  dynamic variable(String key) => contentAsMap['${_variablePrefix}key'];

  /// Gets the channel of this event.
  Channel get channel =>
      _channel == null ? _channel = new Channel.fromPacket(this) : _channel;
}
