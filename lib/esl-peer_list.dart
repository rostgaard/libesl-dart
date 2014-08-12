part of esl;

class PeerList extends IterableBase<Peer> {

  Map <String, Peer> _map = {};

  Iterator get iterator => this._map.values.iterator;

  PeerList.fromMultilineBuffer (String buffer, {String splitOn : '|'}) {
    List<String> keys = new List<String>();
    buffer.split('\n').forEach ((var line) {
     int index = 0;
     Map peer = {};
     if (keys.isEmpty) {
       line.split(splitOn).forEach((f) {
         keys.add(f);
     });
     } else {
       if (!line.isEmpty && line != "+OK") {
         Peer newPeer = new Peer.fromLine(keys, line, splitOn);
         if (!this._map.containsKey(newPeer.key)) {
           this.add(newPeer);
         } else {
           this._map[newPeer.key].mergeGroups(newPeer);
         }
       }
     }
    });
  }

  List toJson() => this.toList(growable: false);

  void add (Peer peer) {
    this._map[peer.key] = peer;
  }

  Peer get (String key) => this._map[key];

  void update (Peer peer) {
    this._map[peer.key] = peer;
  }
}
