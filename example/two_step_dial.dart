// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.example;

import 'package:esl/esl.dart' as ESL;
import 'package:logging/logging.dart';


void main () {
  String new_call_uuid = '';

  /* Changing the root log level propagates to libesl-dart.*/
  Logger.root.level = Level.ALL;

  /* You can use chaining to attach log handlers, or merely set
     it up later using the connection handle. */
  ESL.Connection conn = new ESL.Connection()..log.onRecord.listen(print);

  conn.connect('localhost', 8021).then((_) {
    conn.requestStream.listen((ESL.Packet packet) {
      switch (packet.contentType) {

        /* An authentication request should be responded to be an
           authentication. This is an example on how to do it. */
        case (ESL.ContentType.Auth_Request):

          /* As the authentication call is a future, you can use .then
             blocks to schedule subsequent command or API calls when
             the authentication returns properly. */
          conn.authenticate('1234')
            .then((_) => conn.api('create_uuid').then((ESL.Response response) {
              new_call_uuid = response.rawBody;
              print ('New uuid: $new_call_uuid');

              print ('Dialing receptionist at user/1000');
              return conn.api('originate '
                              '{ignore_early_media=true,'
                              'origination_uuid=$new_call_uuid,'
                              'originate_timeout=5,'
                              'origination_caller_id_number=test,'
                              'origination_caller_id_name=testname}'
                              'user/1000'
                              ' &park()')
                .then((ESL.Response response) {
                if (response.status == ESL.Response.OK) {
                  print("Operator answered. Connecting to 12340003");
                }
              })
              .then((_) {
                conn.api('uuid_setvar $new_call_uuid '
                         'effective_caller_id_number test');
                conn.api('uuid_setvar $new_call_uuid '
                         'effective_caller_id_name testname');
                conn.bgapi ('uuid_transfer $new_call_uuid 1002 XML default');
              });
        }));
      };
    });
  });
}