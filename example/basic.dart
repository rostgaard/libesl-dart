// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.example;

import 'dart:async';
import 'dart:io';

import 'package:esl/constants.dart' as esl;
import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';

Future<Null> main() async {
  /* Changing the root log level propagates to libesl-dart.*/
  Logger.root.level = Level.ALL;
  final List<String> events = <String>[esl.EventType.all];

  esl.Connection conn = new esl.Connection(
      await Socket.connect('localhost', 8021),
      onDisconnect: () => print('oooof'));

  /* FreeSWITCH will send requests to your connection - for instance
    authentication requests.
    In order to respond to them automatically, you can subscribe to
    them from the requestStream. */
  conn.requestStream.listen((esl.Request request) {
    /* An authentication request should be responded to be an
         authentication. This is an example on how to do it. */
    if (request is esl.AuthRequest) {
      /* As the authentication call is a future, you can use .then
           blocks to schedule subsequent command or API calls when
           the authentication returns properly. */
      conn
          .authenticate('ClueCon')
          .then(_checkAuthentication)
          .then((_) => conn.event(events, format: esl.EventFormat.json))
          .catchError((dynamic e) => print(e));
    }
  });

  /* Each connection object has an event stream that can be subscribed
     to globally. This means that you have to handle further dispatching
     manually using, for instance, a switch statement. */
  esl.ChannelList channelList = new esl.ChannelList();

  conn.eventStream.listen((esl.Event event) {
    print(event.eventName);
    switch (event.eventName) {
      case (esl.EventType.custom):
        esl.Channel channel = new esl.Channel.fromEvent(event);
        channelList.update(channel);
        print(channel.variables);
        break;
      case (esl.EventType.channelCreate):
        break;
    }
  });

  conn.noticeStream.listen((esl.Notice notice) => print(notice.runtimeType));

  await new Future<Null>.delayed(new Duration(seconds: 1));
  print(await conn.bgapi('status'));
}

/// Checks authentication reply
void _checkAuthentication(esl.Reply reply) {
  if (reply.status != esl.CommandReply.ok) {
    throw new StateError('Invalid credentials!');
  }
}
