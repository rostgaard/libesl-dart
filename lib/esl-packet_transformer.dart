part of esl;

/**
 *
 */
class PacketTransformer implements StreamTransformer<List<int>, Packet> {
  final StreamController<Packet> _controller = new StreamController<Packet>();
  Packet _currentPacket = new Packet();
  bool _readingHeader = true;
  int _contentLength = 0;
  int _currentChar;
  static final int NEWLINE = '\n'.codeUnits.first;

  @override
  Stream<Packet> bind(Stream<List<int>> stream) {
    stream.listen(_onData, onDone: this._controller.close);
    return _controller.stream;
  }

  void _onData(List<int> bytes) {

    List<int> headerBuffer = [];
    List<int> bodyBuffer   = [];

    for (int offset = 0; offset < bytes.length; offset++) {
      int lastChar = _currentChar;
      _currentChar = bytes[offset];

      if (_readingHeader) {
        if (_currentChar == NEWLINE) {
          if (lastChar == NEWLINE) {
            if (_currentPacket.hasHeader('Content-Length')) {
              _readingHeader = false;
              _contentLength = 0;
              bodyBuffer = [];
            } else {
              /// Skip empty lines.
              if (_currentPacket.headers.isNotEmpty) {
                this._controller.sink.add(_currentPacket);
              }
              _currentPacket = new Packet();
            }

          } else {
            String headerLine = new String.fromCharCodes(headerBuffer);

            if (headerLine.isNotEmpty) {
              List<String> keyValuePair = headerLine.split(':');

              if (keyValuePair.length > 1) {
                _currentPacket.addHeader(keyValuePair[0].trim(), keyValuePair[1].trim());
              } else {
                this._controller.addError (new StateError ("Skipping invalid buffer: ${headerLine}"));
              }
            }
          }
          headerBuffer = [];

        } else {
          headerBuffer.add(_currentChar);
        }
      } else {
        assert (_currentPacket.contentLength > 0);
        bodyBuffer.add(_currentChar);
        _contentLength++;
        if (_contentLength == _currentPacket.contentLength) {
          _currentPacket.content = new String.fromCharCodes(bodyBuffer);
          _readingHeader = true;
          this._controller.sink.add(_currentPacket);

          _currentPacket = new Packet();}
      }
    }
  }
}
