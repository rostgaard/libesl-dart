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
  StreamController<Response> _responseStream = new StreamController.broadcast();
  
  Stream<Packet> get eventStream => this._eventStream.stream;
  Stream<Packet> get requestStream => this._requestStream.stream;
  Stream<Response> get responseStream => this._responseStream.stream;
  
  StreamController<Packet> _nonEventStream = new StreamController.broadcast();
  static int requestCount = Response.count;
  
  /// Private fields used by the packet reader.
  Packet currentPacket = new Packet();
  bool readingHeader = true;
  int contentLength = 0;
  String currentChar;
  String body = "";
  
  Future<Socket> connect(String hostname, int port) {
    return Socket.connect(hostname, port).then((socket) {
      this._socket = socket;
      this._socket.listen(this.packetReader);

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
    Completer<Packet> completer= new Completer<Packet>();
    final int seq = ++requestCount;
    
    this._responseStream.stream.firstWhere((_) => Response.count ==  seq).then ((Response response) {
      completer.complete (response);
    }).catchError((error) {
      completer.completeError (error);
    });

    this._writeCommandToSocket('api $command');
    
    return completer.future.timeout(new Duration(seconds: 5), onTimeout : () => throw new TimeoutException('Failed to get response'));
  }

  void packetReader (List<int> bytes) {
    
    String lineBuffer = "";

    for (int offset = 0; offset < bytes.length; offset++) {
      String lastChar = currentChar;
      currentChar = new String.fromCharCode(bytes[offset]);
      
      if (readingHeader) {
        if (currentChar == '\n') {
          if (lastChar == '\n') {
            if (currentPacket.hasHeader('Content-Length')) {
              readingHeader = false;
              contentLength = 0;
            } else {
              this._dispatch(currentPacket);
              currentPacket = new Packet();
            }

          } else {
            List<String> keyValuePair = lineBuffer.split(':');

            if (keyValuePair.length > 1) {
              currentPacket.addHeader(keyValuePair[0].trim(), keyValuePair[1].trim());
            } else {
              print("Skipping invalid buffer: ${lineBuffer}");
            }
          }
          lineBuffer = "";

        } else {
          lineBuffer = '${lineBuffer}${currentChar}';
        }
      } else {
        assert (currentPacket.contentLength > 0);
        currentPacket.content = '${currentPacket.content}${currentChar}';
        contentLength++;
        if (contentLength == currentPacket.contentLength) {
          readingHeader = true;
          this._dispatch(currentPacket);

          currentPacket = new Packet();}
      }
    }
  }
  
  void _dispatch(Packet packet) {
  
    if (this.currentPacket.isEvent) {
      this._eventStream.add(this.currentPacket);  
    } else if (this.currentPacket.isRequest) {
      this._requestStream.add(this.currentPacket);
    } else if (this.currentPacket.isResponse) {
      this._responseStream.add(new Response.fromPacketBody(this.currentPacket.content.trim()));
   }
    else {
      this._nonEventStream.add(this.currentPacket);
    }
  }

}
