// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.example;

import 'dart:async';

import 'package:esl/constants.dart' as esl;
import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';

esl.PeerList _peerList;

Future main() async {
  /* Changing the root log level propagates to libesl-dart.*/
  Logger.root.level = Level.ALL;
  final List<String> events = ['BACKGROUND_JOB'];

  /* You can use chaining to attach log handlers, or merely set
     it up later using the connection handle. */
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  esl.Connection conn = new esl.Connection();

  /* FreeSWITCH will send requests to your connection - for instance
    authentication requests.
    In order to respond to them automatically, you can subscribe to
    them from the requestStream. */
  conn.requestStream.listen((esl.Packet packet) {
    switch (packet.contentType) {

      /* An authentication request should be responded to be an
         authentication. This is an example on how to do it. */
      case (esl.ContentType.authRequest):

        /* As the authentication call is a future, you can use .then
           blocks to schedule subsequent command or API calls when
           the authentication returns properly. */
        conn
            .authenticate('openreception-tests')
            .then(_checkAuthentication)
            .then((_) => conn.event(events, format: esl.EventFormat.json))
            .catchError((e) => print(e));
        break;

      default:
        break;
    }
  });

  /* Each connection object has an event stream that can be subscribed
     to globally. This means that you have to handle further dispatching
     manually using, for instance, a switch statement. */
  esl.ChannelList channelList = new esl.ChannelList();

  conn.eventStream.listen((esl.Event event) {
    print(event.content);
    switch (event.eventName) {
      case ("CUSTOM"):
        esl.Channel channel = new esl.Channel.fromPacket(event);
        channelList.update(channel);
        print(channel.variables);
        break;
      case ("CHANNEL_CREATE"):
        break;
    }
  });

  conn.noticeStream.listen((packet) => print(packet.contentType));

  void signalDisconnect() => print('Disconnected!');

  print('Connecting...');
  conn.onDone = signalDisconnect;
  await conn.connect('localhost', 8021).whenComplete(() => print('Connected!'));

  await new Future.delayed(new Duration(seconds: 1));
  print(await conn.bgapi('status'));
}

/// Checks authentication reply
void _checkAuthentication(esl.Reply reply) {
  if (reply.status != esl.Reply.ok) {
    throw new StateError('Invalid credentials!');
  }
}
