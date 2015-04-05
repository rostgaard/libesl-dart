part of esl;

/// "Enum" of event formats.
abstract class EventFormat {
  static String Plain = "plain";
  static String Json = "json";
  static String Xml = "xml";

  /**
   * As of now, only JSON format is supported. Most of the raw packet handling
   * is done internally, so the transport serialization should be insignificant
   * for the usage og the library.
   * These commands are implemented in reference to:
   * https://freeswitch.org/confluence/display/FREESWITCH/mod_commands
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
   * Compare an IP to an Access Control List
   */
  Future<Reply> acl(String ipAddress, aclList, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'acl ${ipAddress} ${aclList}',
          new Duration(seconds: timeoutSeconds));

  /**
   * Send an arbitrary API command.
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
   * Authenticate on the FreeSWITCH server.
   */
  Future<Reply> authenticate(String password, {int timeoutSeconds: 10}) =>
      this._subscribeAndSendCommand(
          'auth ${password}',
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
                  '${EventFormat.supportedFormats}'));
    }

    return this._subscribeAndSendCommand(
        'event ${format} ${events.join(' ')}',
        new Duration(seconds: timeoutSeconds));
  }

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
