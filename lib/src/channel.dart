// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 * 'Enum' type representing channel states.
 */
abstract class ChannelState {
  static const String NEW = "CS_NEW";
  static const String INIT = "CS_INIT";
  static const String ROUTING = "CS_ROUTING";
  static const String SOFT_EXECUTE = "CS_SOFT_EXECUTE";
  static const String EXECUTE = "CS_EXECUTE";
  static const String EXCHANGE_MEDIA = "CS_EXCHANGE_MEDIA";
  static const String PARK = "CS_PARK";
  static const String CONSUME_MEDIA = "CS_CONSUME_MEDIA";
  static const String HIBERNATE = "CS_HIBERNATE";
  static const String RESET = "CS_RESET";
  static const String HANGUP = "CS_HANGUP";
  static const String REPORTING = "CS_REPORTING";
  static const String DESTROY = "CS_DESTROY";
}

/**
 * Wrapper class for a channel. Provides easy access to various
 * channel information stored in a packet.
 */
class Channel {
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
  String get UUID => _fields['Unique-ID'];
  String get state => _fields['Channel-State'];
  Map<String, String> get fields => _fields;
  Map<String, dynamic> get variables => _variables;

  /**
   * Extracts the relevant information from the packet and stores
   * it in an internal map.
   */
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

  /**
   * Assemble a channel from fields and variables.
   */
  Channel.assemble(this._fields, this._variables);

  /**
   * Returns a map representation of the channel.
   */
  Map get asMap => {}..addAll(_fields)..addAll({'variables': _variables});

  /**
   * Converts the channel into a map.
   */
  Map toMap() {
    Map tmp = new Map.from(_fields);
    tmp['variables'] = {};
    tmp['variables'].addAll(_variables);
    return tmp;
  }

  /**
   * Two channel is equivalent, if their UUID's are the same
   * - regardless of state.
   */
  @override
  bool operator ==(Channel other) {
    return UUID.toLowerCase() == other.UUID.toLowerCase();
  }

  /**
   * Hashcode follows the convention from the [==] operator.
   */
  @override
  int get hashCode {
    return UUID.toLowerCase().hashCode;
  }

  /**
   * Determine if a channel is inbound.
   */
  bool isInbound() => fields['Call-Direction'] == 'inbound' ? true : false;

  /**
   * Determine if a channel is internal.
   */
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

  /**
   * Gets the channel's name.
   */
  String channelName() => fields['Channel-Name'];
}
