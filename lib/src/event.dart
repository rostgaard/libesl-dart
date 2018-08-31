// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Event subclass. Provides additional (mostly for convenience) accessor
/// methods.
class Event {
  static final String _variablePrefix = 'variable_';

  /// fields of the event packet.
  final UnmodifiableMapView<String, dynamic> fields;

  /// Create a new [Event] from a [Packet] object.
  factory Event.fromPacket(Packet packet) {
    if (!packet.isEvent) {
      throw new StateError('Packet is not event, but ${packet.contentType}');
    }

    if (packet.contentType != _constant.ContentType.textEventJson) {
      throw new StateError('Unsupported event format. '
          'Only values ${supportedEventFormats.join(', ')} are supported. '
          'Got: ${packet.contentType}');
    } else {
      final String decoded = _ascii.decode(packet.payload, allowInvalid: true);
      final Map<String, dynamic> map =
          json.decode(decoded) as Map<String, dynamic>;

      return new Event._internal(new UnmodifiableMapView<String, dynamic>(map));
    }
  }

  Event._internal(this.fields);

  /// Returns the unique ID (packet field `Unique-ID`) of the channel.
  String get uniqueID => fields['Unique-ID'];

  /// Returns name (packet field `Event-Name`) of the event.
  String get eventName => fields['Event-Name'];

  /// Returns event subclass (packet field `Event-Subclass`) of the event.
  String get eventSubclass =>
      fields.containsKey('Event-Subclass') ? fields['Event-Subclass'] : '';

  /// May return List or String.
  dynamic variable(String key) => fields['$_variablePrefix$key'];

  /// Gets the channel of this event.
  Channel get channel => new Channel.fromEvent(this);
}
