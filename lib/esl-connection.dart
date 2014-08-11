part of esl;

abstract class EventFormat {
  static String Plain = "plain";
  static String Json  = "json";
  static String Xml   = "xml";
}


class Connection {

  Socket _socket = null;
  StreamController<Packet> _eventStream = new StreamController.broadcast();
  StreamController<Packet> _requestStream = new StreamController.broadcast();

  Stream<Packet> get eventStream => this._eventStream.stream;
  Stream<Packet> get requestStream => this._requestStream.stream;

  StreamController<Packet> _nonEventStream = new StreamController.broadcast();
  static int requestCount = Response.sequence;

  /// The Job queue is a simple FIFO of Futures that complete in-order.
  Queue<Completer<Response>> jobQueue   = new Queue<Completer<Response>>();

  /// Private fields used by the packet reader.
  Packet currentPacket = new Packet();
  Function onDone = () => null;

  Future<Socket> connect(String hostname, int port) {
    return Socket.connect(hostname, port).then((socket) {
      this._socket = socket;

      this._socket
        .transform(new PacketReader())
        .listen(_dispatch, onDone: onDone);

      return this._socket;
    });
  }

  Future<Packet> _sendCommand (String command) {

    Completer<Packet> completer= new Completer<Packet>();

    this._nonEventStream.stream.first.then ((Packet packet) {
      completer.complete (packet);
    }).catchError((error) {
      completer.completeError (error);
    });

    this._writeCommandToSocket(command);

    return completer.future;
  }

  void _writeCommandToSocket (String command) {
    this._socket.writeln('${command}\n');
  }

  Future<Packet> authenticate (String password) {
    return this._sendCommand ('auth ${password}');
  }

  Future<Packet> event (List<String> events, {String format : ''}) {
    return this._sendCommand('event ${format} ${events.join(' ')}');
  }

  Future<Response> api (String command) {
    Completer<Response> completer= new Completer<Response>();
    this.jobQueue.addLast(completer);

    this._writeCommandToSocket('api $command');

    return completer.future
      ..timeout(new Duration(seconds: 5), onTimeout : () => completer.completeError(new TimeoutException('Failed to get response to command $command')));
  }

  void _dispatch(Packet packet) {
    if (packet.isEvent) {
      this._eventStream.add(packet);
    } else if (packet.isRequest) {
      this._requestStream.add(packet);
    } else if (packet.isResponse) {
      Completer<Response> completer = this.jobQueue.removeFirst();
      if (!completer.isCompleted) {
        completer.complete(new Response.fromPacketBody(packet.content.trim()));
      } else {
        print ('Discarding packet for timed out api command.');
      }
   }
    else {
      this._nonEventStream.add(packet);
    }
  }

}
