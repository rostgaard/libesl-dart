part of esl;

/// "Enum" of event formats.
abstract class EventFormat {
  static const String Plain = "plain";
  static const String Json = "json";
  static const String Xml = "xml";

  /**
   * As of now, only JSON format is supported. Most of the raw packet handling
   * is done internally, so the transport serialization should be insignificant
   * for the usage og the library.
   */
  static List<String> supportedFormats = [Json];
}

/**
 * FreeSWTICH event socket connection.
 */
class Connection {

  final Logger log = new Logger(libraryName);

  Socket _socket = null;

  StreamController<Event> _eventStream = new StreamController.broadcast();
  StreamController<Request> _requestStream = new StreamController.broadcast();

  /**
   * Notice that this is a broadcast stream, and multiple listeners will
   * have to obey the rules of these.
   */
  Stream<Event> get eventStream => this._eventStream.stream;
  Stream<Request> get requestStream => this._requestStream.stream;

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Response>> apiJobQueue = new Queue<Completer<Response>>();

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Reply>> replyQueue = new Queue<Completer<Reply>>();

  Function onDone = () => null;

  Future<Socket> connect(String hostname, int port) {
    return Socket.connect(hostname, port).then((Socket socket) {
      this._socket = socket;

      this._socket.transform(
          new PacketTransformer()).listen(_dispatch, onDone: onDone);

      return this._socket;
    });
  }

  /**
   * Send an arbitrary API command (blocking mode).
   * Command reference can be found at;
   * https://freeswitch.org/confluence/display/FREESWITCH/mod_commands
   */
  Future<Response> api(String command, {int timeoutSeconds: 10}) {
    Completer<Response> completer = new Completer<Response>();
    this.apiJobQueue.addLast(completer);

    return this._sendSerializedCommand(
        'api $command',
        completer,
        new Duration(seconds: timeoutSeconds));
  }

  /**
   * Send an arbitrary API command (non-blocking mode).
   * Command reference can be found at;
   * https://freeswitch.org/confluence/display/FREESWITCH/mod_commands
   */
  Future<Reply> bgapi(String command, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'bgapi ${command}',
          new Duration(seconds: timeoutSeconds));

  /**
   * Authenticate on the FreeSWITCH server.
   */
  Future<Reply> authenticate(String password, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'auth ${password}',
          new Duration(seconds: timeoutSeconds));

  /**
   * Tells FreeSWITCH not to close the socket connect when a channel hangs up.
   * Instead, it keeps the socket connection open until the last event related
   * to the channel has been received by the socket client.
   */
  Future<Reply> linger({int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'linger',
          new Duration(seconds: timeoutSeconds));


  /**
   * Disable socket lingering. See linger above.
   */
  Future<Reply> nolinger({int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'nolinger',
          new Duration(seconds: timeoutSeconds));

  /**
   * Subscribe the socket to [events], which will be pumped into the
   * [eventStream].
   */
  Future<Reply> event(List<String> events, {String format: '',
      int timeoutSeconds: 10}) {
    if (!EventFormat.supportedFormats.contains(format)) {
      return new Future.error(
          new UnsupportedError(
              'Format "$format" unsupported. Supported formats are: '
                  '${EventFormat.supportedFormats.join(', ')}'));
    }

    return this._subscribeAndSendCommand(
        'event ${format} ${events.join(' ')}',
        new Duration(seconds: timeoutSeconds));
  }

  /**
   * The 'myevents' subscription allows your inbound socket connection to
   * behave like an outbound socket connect. It will "lock on" to the events
   * for a particular uuid and will ignore all other events, closing the socket
   * when the channel goes away or closing the channel when the socket
   * disconnects and all applications have finished executing.
   */
  Future<Reply> myevents (String uuid, {String format: '',
      int timeoutSeconds: 10}) {
    if (!EventFormat.supportedFormats.contains(format)) {
      return new Future.error(
          new UnsupportedError(
              'Format "$format" unsupported. Supported formats are: '
                  '${EventFormat.supportedFormats.join(', ')}'));
    }

    return this._subscribeAndSendCommand(
        'myevents $uuid',
        new Duration(seconds: timeoutSeconds));
  }

  /**
   * The divert_events switch is available to allow events that an embedded
   * script would expect to get in the inputcallback to be diverted to the
   * event socket.
   */
  Future<Reply> divert_events(bool on, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'divert_events ${on ? 'on': 'off'}',
          new Duration(seconds: timeoutSeconds));

  /**
   * Close the socket connection.
   */
  Future<Reply> exit({int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'exit',
          new Duration(seconds: timeoutSeconds));

  /**
   * Enable log output. Levels same as the console.conf values
   */
  Future<Reply> logLevel(int level, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'log $level',
          new Duration(seconds: timeoutSeconds));

  /**
   * Disable log output previously enabled by the log command.
   */
  Future<Reply> nolog({int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'nolog',
          new Duration(seconds: timeoutSeconds));
  /**
   * Convenience function to avoidhaving to handle this on every
   * command interface.
   */
  Future<Reply> _subscribeAndSendCommand(String command, Duration timeout) {
    Completer<Reply> completer = new Completer<Reply>();
    this.replyQueue.addLast(completer);

    return this._sendSerializedCommand(command, completer, timeout);
  }

  /**
   * Send pre-serialized command.
   */
  Future _sendSerializedCommand(String command, Completer completer,
      Duration timeout) {
    /// Write the command to socket.
    /// XXX: Figure out if writeln will ever throw an exception.
    this.log.finest('Sending "${command}"');

    try {
      this._socket.writeln('${command}\n');
    } catch (error) {
      this._shutdown();
      return new Future.error(new StateError('Failed to write to socket.'));
    }

    return completer.future..timeout(
        timeout,
        onTimeout: () =>
            completer.completeError(
                new TimeoutException('Failed to get response to '
                                     'command $command')));
  }

  /**
   * Perform a graceful shutdown.
   * Not yet implemented.
   */
  void _shutdown() => throw new UnimplementedError();

  /**
   * Perform a hard socket disconnect.
   */
  Future disconnect() => this._socket.close();

  /**
   * Dispatches a packet by injecting it into the appropriate stream.
   */
  void _dispatch(Packet packet) {
    if (packet.isEvent) {
      this._eventStream.add(new Event.fromPacket(packet));
    } else if (packet.isRequest) {
      this._requestStream.add(new Request.fromPacket(packet));
    } else if (packet.isReply) {
      Completer<Reply> completer = this.replyQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Reply.fromPacket(packet));
      } else {
        this.log.info('Discarding packet for timed out command.');
      }
    } else if (packet.isResponse) {
      Completer<Response> completer = this.apiJobQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Response.fromPacketBody(packet.content.trim()));
      } else {
        this.log.info('Discarding packet for timed out api command.');
      }
    } else {
      this.log.severe('Discarding unknown packet type ${packet.contentType}');
    }
  }
}
