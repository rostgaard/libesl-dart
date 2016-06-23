// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 *
 */
class Peer {
  Map _map = {};
  List<String> _groups = [];
  DateTime _lastSeen = null;

  /// Getters

  String get id => _map['userid'];
  set id(String newId) {
    _map['userid'] = newId;
  }

  String get context => _map['context'];
  String get domain => _map['domain'];
  String get contact => _map['contact'];
  set contact(String con) {
    _map['contact'] = con;
  }

  String get callgroup => _map['callgroup'];
  String get effectiveCallerIdName => _map['effective_caller_id_name'];
  String get effectiveCallerIdNumber => _map['effective_caller_id_number'];
  List<String> get groups => _groups;
  String get key => id;
  DateTime get lastSeen => _lastSeen;
  bool get registered => contact != null;

  Peer();

  Peer.fromLine(List<String> keys, String line, [String seperator = '|']) {
    int index = 0;
    line.split(seperator).forEach((field) {
      _map[keys[index]] = field;
      index++;
    });

    groups.add(_map['group']);
    _map.remove(['group']);

    if (contact.contains('error')) {
      _map['contact'] = null;
    }

    if (index != keys.length) {
      throw new StateError(
          'Line length does not match number of keys. Line buffer: "$line"');
    }
  }

  void register(String contact) {
    _map['contact'] = contact;
    _lastSeen = new DateTime.now();
  }

  void unregister() {
    _map['contact'] = null;
    _lastSeen = new DateTime.now();
  }

  static makeKey(String id) => id;

  void mergeGroups(Peer other) {
    other.groups.forEach((String group) {
      if (!groups.contains(group)) {
        groups.add(group);
      }
    });
  }

  String toString() {
    return key;
  }

  Map toJson() {
    _map['groups'] = groups;
    _map['registered'] = registered;
    return _map;
  }

  /**
   * Determine if two Peer objects are identical.
   *
   * A Peer object is identied by the tuple (userid, domain) and all
   * fields must thus match for two Peer object to be identical.
   */
  @override
  bool operator ==(Object other) =>
      other is Peer && id == other.id && domain == other.domain;

  /**
   *
   */
  int get hashCode => key.hashCode;
}
