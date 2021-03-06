// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 * An iterable collection of [Peer] object.
 * Can be created from a string buffer or built up manually.
 */
class PeerList extends IterableBase<Peer> {
  /**
   * Map used for [Peer] storage. Enables fast lookups, while still
   * preserving the apperance of an [Iterable] from the outside.
   */
  Map<String, Peer> _map = {};

  /**
   * Iterator forward. We can ignore the keys as they are also stored inside
   * the [Peer] object.
   */
  Iterator<Peer> get iterator => _map.values.iterator;

  /**
   * Creates a new empty [PeerList].
   */
  PeerList.empty();

  /**
   * Creates a peerList from a table-formatted string buffer. The format is
   *   <header row fields seperated by [splitOn ], terminated by \n>
   *   <user rows with fields seperated by [splitOn ], terminated by \n>
   *
   * Abbreviated example:
   *  userid|context|domain| ...
   *  1000|default|fs.local| ...
   *  1001|default|fs.local| ...
   *  ...
   */
  PeerList.fromMultilineBuffer(String buffer, {String splitOn: '|'}) {
    List<String> keys = new List<String>();
    buffer.split('\n').forEach((var line) {
      if (keys.isEmpty) {
        line.split(splitOn).forEach((f) {
          keys.add(f);
        });
      } else {
        if (!line.isEmpty && line != "+OK") {
          Peer newPeer = new Peer.fromLine(keys, line, splitOn);
          if (!_map.containsKey(newPeer.key)) {
            add(newPeer);
          } else {
            _map[newPeer.key].mergeGroups(newPeer);
          }
        }
      }
    });
  }

  /**
   * JSON representation is an immutable list representation of the
   * [PeerList] object.
   */
  List toJson() => toList(growable: false);

  /**
   * Add a [Peer] to the list.
   * Replaces the [Peer] element if it is already present.
   */
  void add(Peer peer) => update(peer);

  /**
   * Retrive a Peer from the list.
   * Returns null if the element is not present.
   */
  Peer get(String key) => _map[key];

  /**
   * Replaces the [Peer] element if it is already present.
   */
  void update(Peer peer) {
    _map[peer.key] = peer;
  }
}
