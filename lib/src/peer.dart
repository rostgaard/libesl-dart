// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// Peer model class as represented by ESL `list_users` API command.
class Peer {
  Map<String, dynamic> _map = <String, dynamic>{};
  List<String> _groups = <String>[];
  DateTime _lastSeen;

  /// Default constructor. Creates and un-initialized [Peer] object.
  Peer();

  /// Parsing constructor. Creates a new [Peer] object by parsing [line]
  /// using [seperator] as delimiter and [keys] as header fields.
  Peer.fromLine(List<String> keys, String line, [String seperator = '|']) {
    int index = 0;
    line.split(seperator).forEach((String field) {
      _map[keys[index]] = field;
      index++;
    });

    groups.add(_map['group']);
    _map.remove(<String>['group']);

    if (contact.contains('error')) {
      _map['contact'] = null;
    }

    if (index != keys.length) {
      throw new StateError(
          'Line length does not match number of keys. Line buffer: "$line"');
    }

    _map['groups'] = groups;
    _map['registered'] = registered;
  }

  /// User ID of the [Peer].
  String get id => _map['userid'];
  set id(String newId) {
    _map['userid'] = newId;
  }

  /// Returns the peer context
  String get context => _map['context'];

  /// Returns the peer domain
  String get domain => _map['domain'];

  /// Returns the peer contact uri as a String
  String get contact => _map['contact'];

  /// Update the peer contact uri.
  set contact(String con) {
    _map['contact'] = con;
  }

  /// Returns the peer callgroup
  String get callgroup => _map['callgroup'];

  /// Returns the peer caller ID name
  String get effectiveCallerIdName => _map['effective_caller_id_name'];

  /// Returns the peer caller ID number
  String get effectiveCallerIdNumber => _map['effective_caller_id_number'];

  /// Returns the peer groups
  List<String> get groups => _groups;

  /// Value suitable for map key.
  @deprecated
  String get key => id;

  /// When the [Peer] was last seen
  DateTime get lastSeen => _lastSeen;

  /// Whether the [Peer] is registered.
  bool get registered => contact != null;

  /// Register the peer with [contact] endpoint.
  void register(String contact) {
    _map['contact'] = contact;
    _lastSeen = new DateTime.now();
  }

  /// Unregister the peer.
  void unregister() {
    _map['contact'] = null;
    _lastSeen = new DateTime.now();
  }

  /// Builds a key suitable for map storage of [Peer] objects.
  @deprecated
  static String makeKey(String id) => id;

  /// Merges groups from [other] [Peer] with this objects [Peer]'s'.
  void mergeGroups(Peer other) {
    other.groups.forEach((String group) {
      if (!groups.contains(group)) {
        groups.add(group);
      }
    });
  }

  /// Returns a string represention of the [Peer], showing only the [id].
  @override
  String toString() => id;

  /// Returns a Map representation of the [Peer] suitable and safe for
  /// serialization.
  UnmodifiableMapView<String, dynamic> toJson() =>
      new UnmodifiableMapView<String, dynamic>(_map);

  /// Determine if two Peer objects are identical.
  ///
  /// A Peer object is identied by the tuple (userid, domain) and all
  /// fields must thus match for two Peer object to be identical.
  @override
  bool operator ==(Object other) =>
      other is Peer && id == other.id && domain == other.domain;

  /// The hashcode of the object. Hashes are identical for [Peer] objects
  /// that share [id].
  @override
  int get hashCode => id.hashCode;
}
