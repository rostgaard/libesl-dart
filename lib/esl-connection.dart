part of esl;

abstract class EventFormat {
  static String Plain = "plain";
  static String Json  = "json";
  static String Xml   = "xml";

  static List<String> supportedFormats = [Json];
}

class Connection {

  final Logger log = new Logger (libraryName);

  Socket _socket = null;

  StreamController<Event> _eventStream = new StreamController.broadcast();
  StreamController<Packet> _requestStream = new StreamController.broadcast();

  /**
   * Notice that this is a broadcast stream, and multiple listeners will
   * have to obey the rules of these.
   */
  Stream<Event>  get eventStream => this._eventStream.stream;
  Stream<Packet> get requestStream => this._requestStream.stream;

  StreamController<Packet> _nonEventStream = new StreamController.broadcast();

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Response>> apiJobQueue   = new Queue<Completer<Response>>();

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Reply>> replyQueue   = new Queue<Completer<Reply>>();

  Function onDone = () => null;

  Future<Socket> connect(String hostname, int port) {
    return Socket.connect(hostname, port).then((Socket socket) {
      this._socket = socket;

      this._socket
        .transform(new PacketReader())
        .listen(_dispatch, onDone: onDone);

      return this._socket;
    });
  }

  Future<Response> api (String command, {int timeoutSeconds : 10}) {
      Completer<Response> completer= new Completer<Response>();
      this.apiJobQueue.addLast(completer);

      return this._sendSerializedCommand('api $command', completer, new Duration(seconds : timeoutSeconds));
  }

  /**
   * Authenticate on the FreeSWITCH server.
   */
  Future<Reply> authenticate (String password, {int timeoutSeconds : 10})
    => this._subscribeAndSendCommand('auth ${password}', new Duration(seconds : timeoutSeconds));

  /**
   *
   */
  Future<Reply> event (List<String> events, {String format : '', int timeoutSeconds : 10}) {
    if (!EventFormat.supportedFormats.contains(format)) {
      throw new UnsupportedError('Format "$format" unsupported. Supported formats are: ${EventFormat.supportedFormats}');
    }
    return this._subscribeAndSendCommand('event ${format} ${events.join(' ')}', new Duration(seconds : timeoutSeconds));
  }

  /**
   * Convenience function for avoiding having to handle this on every command interface.
   */
  Future<Reply> _subscribeAndSendCommand (String command, Duration timeout) {
    Completer<Reply> completer= new Completer<Reply>();
    this.replyQueue.addLast(completer);

   return this._sendSerializedCommand (command, completer, timeout);
  }

  Future _sendSerializedCommand (String command, Completer completer, Duration timeout) {
      /// Write the command to socket.
      /// XXX: Figure out if writeln will ever throw an exception.
      this.log.finest('Sending "${command}"');
      this._socket.writeln('${command}\n');

    return completer.future
      ..timeout(timeout,
          onTimeout : () =>
              completer.completeError(new TimeoutException('Failed to get response to command $command')));
   }

  Future disconnect() => this._socket.close();

  void _dispatch(Packet packet) {
    if (packet.isEvent) {
      this._eventStream.add(new Event.fromPacket(packet));
    } else if (packet.isRequest) {
      this._requestStream.add(packet);
    } else if (packet.isReply) {
      Completer<Reply> completer = this.replyQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Reply.fromPacker(packet));
      } else {
        this.log.info ('Discarding packet for timed out command.');
      }
    } else if (packet.isResponse) {
      Completer<Response> completer = this.apiJobQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Response.fromPacketBody(packet.content.trim()));
      } else {
        this.log.info ('Discarding packet for timed out api command.');
      }
    }
    else {
      this.log.info ('Discarding unknown packet type ${packet.contentType}');
    }
  }

  Future<Packet> _sendCommand(String command) {

    Completer<Packet> completer= new Completer<Packet>();

    this._nonEventStream.stream.first.then((Packet packet) {
      completer.complete(packet);
    }).catchError((error) {
      completer.completeError(error);
    });

    this._writeCommandToSocket(command);

    return completer.future;
  }

  void _writeCommandToSocket (String command) {
    this._socket.writeln('${command}\n');
  }
}
