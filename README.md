libesl-dart
===========

FreeSWITCH event socket client library written in Dart

The project is in an early state, and contributions are very welcome.
See the examples directory for usage.

## Basic usage


### Connecting

```dart
ESL.Connection conn = new ESL.Connection();
conn.connect('example.com', 8021);
```

### Authenticating

The first thing you will need to do after having connected, is authenticate.
Libesl-dart is fully asynchronous and uses streams for the events, responses 
and requests coming from the FreeSWITCH server.

This means that the way you handle authentication, is that you setup a listener
for `auth/request` requests coming from the server.

#### Example code
```dart
ESL.Connection conn = new ESL.Connection();
conn.requestStream.listen((ESL.Packet packet) {
  switch (packet.contentType) {
    case (ESL.ContentType.Auth_Request):
      conn.authenticate('ClueCon');
      break;
    default:
      break;
  }
});

conn.connect('example.com', 8021);
```



## Log trace

Every ESL connection object has its own logger object that is muted by default.
It uses the "logging" package[1] from pub.dartlang.org, so you may need to 
include this package in your project.

In order to tap into the log trace you need to set an `onRecord` handler.
This can be done at any time, but makes most sense doing at instantiation.

#### Example code
```dart
ESL.Connection conn = new ESL.Connection()
                             ..log.onRecord.listen(print);
```

This makes every log entry go to the root Logger, and inherit its loglevel.

------
[1] https://pub.dartlang.org/packages/logging
