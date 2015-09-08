// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl;

/**
 * Transformer for converting raw bytes into [Packet] objects.
 * Handles the low-level parsing of network traffic, or any other byte stream
 * for that matter, stores them in a buffer and encapsulates them in [Packet]
 * objects which the [Connection] then re-casts and injects into the
 * appropriate steam - for instance event stream.
 *
 * Can also be used standalone for parsing, for instance, packet dumps.
 */
class PacketTransformer implements StreamTransformer<List<int>, Packet> {
  final StreamController<Packet> _controller = new StreamController<Packet>();
  Packet _currentPacket = new Packet();
  List<int> headerBuffer = [];
  List<int> bodyBuffer   = [];
  bool _readingHeader = true;
  int _contentLength = 0;
  int _currentChar;
  static final int NEWLINE = '\n'.codeUnits.first;

  @override
  Stream<Packet> bind(Stream<List<int>> stream) {
    stream.listen(_onData, onDone: this._controller.close);
    return _controller.stream;
  }

  /**
   * Callback for receiving and processing bytes.
   * Supports segmented transfers, such as TCP buffers.
   */
  void _onData(List<int> bytes) {

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
              if (!_currentPacket.hasHeader('Content-Type') &&
                   _currentPacket.headers.isNotEmpty) {
                this._controller.sink.addError
                  (new StateError
                      ('Bad header received: ${_currentPacket.headers}'));
              }
              /// Skip empty lines.
              else if (_currentPacket.headers.isNotEmpty) {
                this._controller.sink.add(_currentPacket);
              }
              _currentPacket = new Packet();
            }

          } else {
            String headerLine = new String.fromCharCodes(headerBuffer);

            /// Ignore short lines.
            if (headerLine.length > 1) {
              int splitIndex = headerLine.indexOf(':');
              if (splitIndex > 0) {
                String key = headerLine.substring(0, splitIndex);
                String value = headerLine.substring(splitIndex+1);
                _currentPacket.addHeader(key.trim(),
                                         value.trim());
              } else {
                this._controller.addError
                  (new StateError ('Skipping invalid buffer: "${headerLine}"'));
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

          /// Sink on the packet.
          this._controller.sink.add(_currentPacket);

          /// Clear the state.
          bodyBuffer = [];
          _currentPacket = new Packet();}
      }
    }
  }
}
