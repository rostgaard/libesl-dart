// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/// As of now, only JSON format is supported. Most of the raw packet
/// handling is done internally, so the transport deserialization should
/// be insignificant for the usage of this library.
const List<String> supportedEventFormats = const <String>[
  _constant.EventFormat.json
];

/// FreeSWITCH event socket connection.
/// TODO: Create notice packet.
/// TODO: Remove timout seconds
class Connection {
  final Logger _log = new Logger('esl');

  final Socket _socket;
  final Function _onDisconnect;

  final StreamController<Event> _eventController =
      new StreamController<Event>.broadcast();
  final StreamController<Request> _requestStream =
      new StreamController<Request>.broadcast();
  final StreamController<Packet> _noticeStream =
      new StreamController<Packet>.broadcast();

  /// Default constructor.
  Connection(this._socket, {void onDisconnect()})
      : _onDisconnect = onDisconnect {
    _socket
        .transform(new PacketTransformer())
        .listen(_dispatch, onDone: _onDone);
  }

  /// Stream that spawns a [Event] object every time the ESL socket sends
  /// an event packet.
  Stream<Event> get eventStream => _eventController.stream;

  /// Stream that spawns a [Request] object every time the ESL socket sends
  /// a request packet.
  Stream<Request> get requestStream => _requestStream.stream;

  /// Stream that spawns a [Packet] object every time the ESL socket sends
  /// a notice packet.
  Stream<Packet> get noticeStream => _noticeStream.stream;

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Response>> _apiJobQueue = new Queue<Completer<Response>>();

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Reply>> _replyQueue = new Queue<Completer<Reply>>();

  /// Performs Socket-post-mortem cleanup.
  Future<Null> _onDone() async {
    _log.finest('Disconnected. Closing streams');
    _apiJobQueue.forEach((Completer<Response> c) {
      try {
        c.completeError(
            new StateError('Transport channel has been disconnected'));
      } catch (e) {
        _log.warning('Failed to complete ticket in api job queue', e);
      }
    });

    _apiJobQueue.clear();

    _replyQueue.forEach((Completer<Reply> c) {
      try {
        c.completeError(new StateError('Socket has been disconnected'));
      } catch (e) {
        _log.warning('Failed to complete ticket in reply queue', e);
      }
    });

    _replyQueue.clear();
    await _noticeStream.close();
    await _eventController.close();
    await _requestStream.close();
    await _socket.close();

    /// Notify of the disconnect
    if (_onDisconnect != null) _onDisconnect();
  }

  /// Send an arbitrary API command (blocking mode).
  ///
  /// Command reference can be found at;
  /// https://freeswitch.org/confluence/display/FREESWITCH/mod_commands
  Future<Response> api(String command) async {
    final Completer<Response> completer = new Completer<Response>();
    _apiJobQueue.addLast(completer);

    await _sendSerializedCommand('api $command', completer);

    return completer.future;
  }

  /// Send an arbitrary API command (non-blocking mode).
  ///
  /// Command reference can be found at;
  /// https://freeswitch.org/confluence/display/FREESWITCH/mod_commands
  Future<Reply> bgapi(String command, {String jobUuid: ''}) async {
    final String commandString =
        '$command' + (jobUuid.isNotEmpty ? '\nJob-UUID: $jobUuid' : '');

    return _subscribeAndSendCommand('bgapi $commandString');
  }

  /// Authenticate on the FreeSWITCH server.
  Future<Reply> authenticate(String password) =>
      _subscribeAndSendCommand('auth $password');

  /// Tells FreeSWITCH not to close the socket connect when a channel
  /// hangs up. Instead, it keeps the socket connection open until the
  /// last event related to the channel has been received by
  /// the socket client.
  Future<Reply> linger() => _subscribeAndSendCommand('linger');

  /// Disable socket lingering. See linger above.
  Future<Reply> nolinger() => _subscribeAndSendCommand('nolinger');

  /// Subscribe the socket to [events], which will be pumped into
  /// the [eventStream].
  ///
  /// The optional event [format] parameter will default to
  /// [_constant.EventFormat.json], as this is
  Future<Reply> event(List<String> events, {String format: ''}) async {
    return _subscribeAndSendCommand('event $format ${events.join(' ')}');
  }

  /// The 'myevents' subscription allows your inbound socket connection to
  /// behave like an outbound socket connect. It will "lock on" to the
  /// events for a particular uuid and will ignore all other events,
  /// closing the socket when the channel goes away or closing the channel
  /// when the socket disconnects and all applications have
  /// finished executing.
  Future<Reply> myevents(String uuid, {String format: ''}) async {
    if (!supportedEventFormats.contains(format)) {
      throw new UnsupportedError(
          'Format "$format" unsupported. Supported formats are: '
          '${supportedEventFormats.join(', ')}');
    }

    return _subscribeAndSendCommand('myevents $uuid');
  }

  /// The divert_events switch is available to allow events that an embedded
  /// script would expect to get in the inputcallback to be diverted to the
  /// event socket.
  Future<Reply> divertEvents(bool on) =>
      _subscribeAndSendCommand('divert_events ${on ? 'on': 'off'}');

  /// Close the socket connection.
  Future<Reply> exit() => _subscribeAndSendCommand('exit');

  /// Enable log output. Levels same as the console.conf values
  Future<Reply> logLevel(int level) => _subscribeAndSendCommand('log $level');

  /// Disable log output previously enabled by the log command.
  Future<Reply> nolog() => _subscribeAndSendCommand('nolog');

  /// Specify event types to listen for. Note, this is not a filter out but
  /// rather a "filter in," that is, when a filter is applied only the
  /// filtered values are received. Multiple filters on a socket
  /// connection are allowed.
  Future<Reply> filter(String eventHeader, String valueToFilter) =>
      _subscribeAndSendCommand('filter $eventHeader $valueToFilter');

  /// Specify the events which you want to revoke the filter. filter delete
  /// can be used when some filters are applied wrongly or when there is
  /// no use of the filter.
  ///
  /// Example:
  ///    filterDelete('Event-Name', 'HEARTBEAT')
  ///
  Future<Reply> filterDelete(String eventHeader, String valueToFilter) =>
      _subscribeAndSendCommand('filter delete $eventHeader $valueToFilter');

  /// Send an event into the event system (multi line input for headers)
  Future<Reply> sendevent(String eventName) =>
      _subscribeAndSendCommand('sendevent $eventName');

  /// Suppress the specified type of event. Useful when you want to allow
  /// 'event all' followed by 'nixevent <some_event>' to see all but 1 type
  /// of event.
  Future<Reply> nixevent(String eventTypes) =>
      _subscribeAndSendCommand('nixevent $eventTypes');

  /// Disable all events that were previously enabled with event.
  Future<Reply> noEvents() => _subscribeAndSendCommand('noevents');

  /// Convenience function to avoid having to handle this on every
  /// command interface.
  Future<Reply> _subscribeAndSendCommand(String command) async {
    Completer<Reply> completer = new Completer<Reply>();
    _replyQueue.addLast(completer);

    await _sendSerializedCommand(command, completer);

    return completer.future;
  }

  /// Send pre-serialized command.
  Future _sendSerializedCommand(
      String command, Completer<dynamic> completer) async {
    try {
      _log.finest('Sending "$command"');

      /// Write the command to socket.
      _socket.writeln('$command\n');
    } catch (error, stackTrace) {
      final msg = 'Failed to send command "$command" - socket write failed.'
          ' Error: $error';
      _log.shout(msg, error, stackTrace);
      completer.completeError(new StateError(msg), stackTrace);
    }
  }

  /// Dispatches a packet by injecting it into the appropriate stream.
  void _dispatch(Packet packet) {
    if (packet.isEvent) {
      _eventController.add(new Event.fromPacket(packet));
    } else if (packet.isRequest) {
      _requestStream.add(new Request.fromPacket(packet));
    } else if (packet.isReply) {
      Completer<Reply> completer = _replyQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Reply.fromPacket(packet));
      } else {
        _log.info('Discarding packet for timed out command.');
      }
    } else if (packet.isResponse) {
      Completer<Response> completer = _apiJobQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Response.fromPacket(packet));
      } else {
        _log.info('Discarding packet for timed out api command.');
      }
    } else if (packet.isNotice) {
      _noticeStream.add(packet);
    } else {
      _log.severe('Discarding unknown packet type ${packet.contentType}');
    }
  }
}
