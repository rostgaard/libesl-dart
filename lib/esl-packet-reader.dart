part of esl;

class PacketReader implements StreamTransformer<List<int>, Packet> {
  final StreamController<Packet> _controller = new StreamController<Packet>();
  Packet _currentPacket = new Packet();
  bool _readingHeader = true;
  int _contentLength = 0;
  String _currentChar;

  @override
  Stream<Packet> bind(Stream<List<int>> stream) {
    stream.listen(_onData);
    return _controller.stream;
  }

  void _onData(List<int> bytes) {
    String lineBuffer = "";

    for (int offset = 0; offset < bytes.length; offset++) {
      String lastChar = _currentChar;
      _currentChar = new String.fromCharCode(bytes[offset]);

      if (_readingHeader) {
        if (_currentChar == '\n'.codeUnits.first) {
          if (lastChar == '\n') {
            if (_currentPacket.hasHeader('Content-Length')) {
              _readingHeader = false;
              _contentLength = 0;
            } else {
              this._controller.sink.add(_currentPacket);
              _currentPacket = new Packet();
            }

          } else {
            List<String> keyValuePair = lineBuffer.split(':');

            if (keyValuePair.length > 1) {
              _currentPacket.addHeader(keyValuePair[0].trim(), keyValuePair[1].trim());
            } else {
              print("Skipping invalid buffer: ${lineBuffer}");
            }
          }
          lineBuffer = "";

        } else {
          lineBuffer = '${lineBuffer}${_currentChar}';
        }
      } else {
        assert (_currentPacket.contentLength > 0);
        _currentPacket.content = '${_currentPacket.content}${_currentChar}';
        _contentLength++;
        if (_contentLength == _currentPacket.contentLength) {
          _readingHeader = true;
          this._controller.sink.add(_currentPacket);

          _currentPacket = new Packet();}
      }
    }
  }
}
