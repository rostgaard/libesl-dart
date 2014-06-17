import 'dart:convert';
import 'lib/esl.dart' as ESL;

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
        /*conn.authenticate('1234').then((ESL.Packet packet) {
          conn.event(['all'], format : ESL.EventFormat.Json);
        });*/
      
      
      conn.authenticate('1234')
        .then((_) => conn.event(['all'], format : ESL.EventFormat.Json))
        .then((_) => conn.api('list_users')
          .then(loadPeerListFromPacket))
        .then((_) => print(JSON.encode (peerList)));
      
      break;
      default:
        
        break;
    }
  });

  conn.connect('localhost', 8021);
}
  

void loadPeerListFromPacket (ESL.Packet packet) {
 peerList = new ESL.PeerList.fromMultilineBuffer(packet.content);
}