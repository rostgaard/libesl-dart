part of esl;

/**
 *
 */
class Peer {

  Map          _map    = {};
  List<String> _groups = [];
  DateTime     _lastSeen = null;

  /// Getters
  String       get ID                      => this._map['userid'];
  String       get context                 => this._map['context'];
  String       get domain                  => this._map['domain'];
  String       get contact                 => this._map['contact'];
  String       get callgroup               => this._map['callgroup'];
  String       get effectiveCallerIdName   => this._map['effective_caller_id_name'];
  String       get effectiveCallerIdNumber => this._map['effective_caller_id_number'];
  List<String> get groups                  => this._groups;
  String       get key                     => this.ID;
  DateTime     get lastSeen                => this._lastSeen;
  bool         get registered              => this.contact != null;

  Peer.fromLine (List<String> keys, String line, [String seperator = '|']) {
    int index = 0;
    line.split(seperator).forEach((field) {
      this._map[keys[index]] = field;
      index++;
    });

    this.groups.add(this._map['group']);
    this._map.remove(['group']);

    if (this.contact.contains('error')) {
      this._map['contact'] = null;
    }

    if (index != keys.length) {
      throw new StateError('Line length does not match number of keys. Line buffer: "$line"');
    }
  }


  void register (String contact) {
    this._map['contact'] = contact;
    this._lastSeen = new DateTime.now();
  }

  void unregister () {
    this._map['contact'] = null;
    this._lastSeen = new DateTime.now();
  }

  static makeKey (String ID) => ID;

  void mergeGroups (Peer other) {
    other.groups.forEach((String group) {
      if (!this.groups.contains(group)) {
        this.groups.add (group);
      }
    });
  }

  String toString () {
    return this.key;
  }

  Map toJson () {
    this._map['groups'] = this.groups;
    this._map['registered'] = this.registered;
    return this._map;
  }


  /**
   * Determine if two Peer objects are identical.
   *
   * A Peer object is identied by the tuple (userid, domain) and all
   * fields must thus match for two Peer object to be identical.
   */
  @override
  bool operator == (Peer other) {
    return this.ID      == other.ID     &&
           this.domain  == other.domain;
  }

  /**
   *
   */
  int get hashCode => this.key.hashCode;
}

