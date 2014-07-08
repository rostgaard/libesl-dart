import '../lib/esl.dart' as ESL;

ESL.PeerList peerList = null;

main() {
  
  ESL.Connection conn = new ESL.Connection();
  ESL.ChannelList channelList = new ESL.ChannelList(); 
  
  conn.eventStream.listen((ESL.Packet packet) {
      switch (packet.eventName) {
        case ("CHANNEL_STATE"):
          channelList.update(new ESL.Channel.fromPacket(packet));
          break;
        case ("CHANNEL_CREATE"):
          break;
      }
  });
  
  conn.requestStream.listen((ESL.Packet packet) {
    switch (packet.contentType) {
      case (ESL.ContentType.Auth_Request):
      
      conn.authenticate('1234').then((packet) => print(packet.headers))
        .then((_) => conn.event(['all'], format : ESL.EventFormat.Json))
        .then((_) => conn.api('status').then(print))
        .then((_) => conn.api('list_users')
        .then((packet) => print(new ESL.PeerList.fromMultilineBuffer(packet.rawBody)))
        .then((_) {
          for (int i = 0; i < 100; i++) {
            sendRequest(i, conn);
          }
        }));
      
      break;
      default:
        
        break;
    }
  });

  conn.connect('localhost', 8021);
}

void sendRequest (int seq, ESL.Connection conn) {
  conn.api('echo $seq').then((ESL.Response response) {
    print('$seq, ${response.rawBody}');
    assert (int.parse(response.rawBody) == seq);
    });
}
  

void loadPeerListFromPacket (ESL.Packet packet) {
 peerList = new ESL.PeerList.fromMultilineBuffer(packet.content);
}