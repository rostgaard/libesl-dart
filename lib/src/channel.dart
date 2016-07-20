// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

///'Enum' type representing channel states.
abstract class _ChannelState {
  // static const String _new = "CS_NEW";
  // static const String _init = "CS_INIT";
  // static const String _routing = "CS_ROUTING";
  // static const String _softExecute = "CS_SOFT_EXECUTE";
  // static const String _execute = "CS_EXECUTE";
  // static const String _exchangeMedia = "CS_EXCHANGE_MEDIA";
  // static const String _park = "CS_PARK";
  // static const String _consume_media = "CS_CONSUME_MEDIA";
  // static const String _hibernate = "CS_HIBERNATE";
  // static const String _reset = "CS_RESET";
  // static const String _hangup = "CS_HANGUP";
  // static const String _reporting = "CS_REPORTING";
  static const String _destroy = "CS_DESTROY";
}

/// Wrapper class for a channel. Provides easy access to various channel
/// information stored in a packet.
class Channel {
  /// Null channel identifier. To be removed.
  @deprecated
  static const String nullChannelID = null;

  static final List<String> excludedFields = [
    'Event-Name',
    'Core-UUID',
    'FreeSWITCH-Hostname',
    'FreeSWITCH-IPv4',
    'FreeSWITCH-IPv6',
    'Event-Date-Local',
    'Event-Date-GMT',
    'Event-Date-Timestamp',
    'Event-Calling-File',
    'Event-Calling-Function',
    'Event-Calling-Line-Number'
  ];

  Map<String, String> _fields = new Map<String, String>();
  Map<String, dynamic> _variables = new Map<String, dynamic>();

  /// Assemble a channel from fields and variables.
  Channel.assemble(this._fields, this._variables);

  /// Extracts the relevant information from the packet and stores it in an
  /// internal map.
  Channel.fromPacket(Packet packet) {
    packet.contentAsMap.forEach((key, value) {
      if (key.startsWith("variable_")) {
        String keyNoPrefix = (key.split("variable_")[1]);
        _variables[keyNoPrefix] = value;
      } else if (!excludedFields.contains(key)) {
        _fields[key] = value;
      }
    });
  }

  /// Get the unique ID (uuid) of the channel.
  String get uuid => _fields['Unique-ID'];

  /// Get the current channel state.
  String get state => _fields['Channel-State'];

  /// Get the fields of the channel.
  Map<String, String> get fields => _fields;

  /// Get the variables of the channel.
  Map<String, dynamic> get variables => _variables;

  /// Returns a map representation of the channel.
  /// Deprecated, use [toMap()] instead.
  @deprecated
  Map get asMap => {}..addAll(_fields)..addAll({'variables': _variables});

  /// Returns a map representation of the channel.
  Map toMap() => new Map.from(_fields)..addAll({'variables': _variables});

  /// Two channel are equivalent, if their UUID's are the same regardless
  /// of state or variables.
  @override
  bool operator ==(Object other) =>
      other is Channel && uuid.toLowerCase() == other.uuid.toLowerCase();

  /// Hashcode follows the convention from the [==] operator.
  @override
  int get hashCode {
    return uuid.toLowerCase().hashCode;
  }

  /// Determine if a channel is inbound.
  bool isInbound() => fields['Call-Direction'] == 'inbound' ? true : false;

  /// Determine if a channel is internal.
  bool isInternal() {
    String cName = channelName();

    if (!cName.startsWith('sofia/')) {
      throw new ArgumentError('only sofia channels are supported. Got: $cName');
    }

    String profile = cName.split('/')[1];

    if (profile == 'internal') {
      return true;
    } else if (profile == 'external') {
      return false;
    }

    throw new ArgumentError(
        'Failed to detect profile in channel name \'$cName\'.');
  }

  /// Gets the channel's name.
  String channelName() => fields['Channel-Name'];
}
