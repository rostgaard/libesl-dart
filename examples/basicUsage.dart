import 'dart:async';

import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';
ESL.PeerList peerList = null;

main() {

  /* Changing the root log level propagates to libesl-dart.*/
  Logger.root.level = Level.ALL;

  /* You can use chaining to attach log handlers, or merely set
     it up later using the connection handle. */
  ESL.Connection conn = new ESL.Connection()..log.onRecord.listen(print);

  /* FreeSWITCH will send requests to your connection - for instance
    authentication requests.
    In order to respond to them automatically, you can subscribe to
    them from the requestStream. */
  conn.requestStream.listen((ESL.Packet packet) {
    switch (packet.contentType) {

      /* An authentication request should be responded to be an
         authentication. This is an example on how to do it. */
      case (ESL.ContentType.Auth_Request):

        /* As the authentication call is a future, you can use .then
           blocks to schedule subsequent command or API calls when
           the authentication returns properly. */
        conn.authenticate('1234').then(checkAuthentication)
          .then((_) => conn.event(['all'], format: ESL.EventFormat.Json))
          .then((_) => conn.api('list_users'))
          .then((packet) => print(new ESL.PeerList.fromMultilineBuffer(packet.rawBody)))
          .then((_) {
          List<int> sequence = new List.generate(100, (int index) => index);
          return Future.wait(sequence.map((int i) => sendRequest(i, conn)));
        })
        .then((_) => conn.api('status').then(print))
        .catchError((e) => print (e));
        break;

      default:
        break;
    }
  });

  /* Each connection object has an event stream that can be subscribed
     to globally. This means that you have to handle further dispatching
     manually using, for instance, a switch statement. */
  ESL.ChannelList channelList = new ESL.ChannelList();

  conn.eventStream.listen((ESL.Packet packet) {
    switch (packet.eventName) {
      case ("CUSTOM"):

        ESL.Channel channel = new ESL.Channel.fromPacket(packet);
        channelList.update(channel);
        print (channel.variables);
        break;
      case ("CHANNEL_CREATE"):
        break;
    }
  });


  void signalDisconnect() => print('Disconnected!');

  print('Connecting...');
  conn..onDone = signalDisconnect
      ..connect('localhost', 8021)
      .whenComplete(() => print ('Connected!'));
}

void checkAuthentication(ESL.Reply reply) {
  if (reply.status != ESL.Reply.OK) {
    throw new StateError('Invalid credentials!');
  }
}


Future sendRequest(int seq, ESL.Connection conn) {
  return conn.api('echo $seq').then((ESL.Response response) {
    print('$seq, ${response.rawBody}');
    assert(int.parse(response.rawBody) == seq);
  });
}

void loadPeerListFromPacket(ESL.Packet packet) {
  peerList = new ESL.PeerList.fromMultilineBuffer(packet.content);
}
