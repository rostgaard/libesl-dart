// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.
library esl.packet_transformer;

import 'dart:async';

import 'package:esl/esl.dart';

/// Transformer for converting raw bytes into [Packet] objects.
///
/// Handles the low-level parsing of network traffic, or any other byte
/// stream for that matter, stores them in a buffer and encapsulates them
/// in [Packet] objects for which a [Connection] object may re-casts them
/// and forward them to the appropriate steam - for instance event stream.
///
/// Can also be used standalone for parsing, for instance, packet dumps.
class PacketTransformer implements StreamTransformer<List<int>, Packet> {
  final StreamController<Packet> _controller = new StreamController<Packet>();
  Packet _currentPacket = new Packet();
  List<int> _headerBuffer = [];
  List<int> _bodyBuffer = [];
  bool _readingHeader = true;
  int _contentLength = 0;
  int _currentChar;
  static final int _newLine = '\n'.codeUnits.first;

  ///Transform the incoming `stream's` events into [Packet] object.
  @override
  Stream<Packet> bind(Stream<List<int>> stream) {
    stream.listen(_onData, onDone: _controller.close);
    return _controller.stream;
  }

  /// Callback for receiving and processing bytes.
  ///
  /// Supports segmented transfers, such as TCP buffers.
  void _onData(List<int> bytes) {
    for (int offset = 0; offset < bytes.length; offset++) {
      int lastChar = _currentChar;
      _currentChar = bytes[offset];

      if (_readingHeader) {
        if (_currentChar == _newLine) {
          if (lastChar == _newLine) {
            if (_currentPacket.hasHeader('Content-Length')) {
              _readingHeader = false;
              _contentLength = 0;
              _bodyBuffer = [];
            } else {
              if (!_currentPacket.hasHeader('Content-Type') &&
                  _currentPacket.headers.isNotEmpty) {
                _controller.sink.addError(new StateError(
                    'Bad header received: ${_currentPacket.headers}'));
              }

              // Skip empty lines.
              else if (_currentPacket.headers.isNotEmpty) {
                _controller.sink.add(_currentPacket);
              }
              _currentPacket = new Packet();
            }
          } else {
            String headerLine = new String.fromCharCodes(_headerBuffer);

            // Ignore short lines.
            if (headerLine.length > 1) {
              int splitIndex = headerLine.indexOf(':');
              if (splitIndex > 0) {
                String key = headerLine.substring(0, splitIndex);
                String value = headerLine.substring(splitIndex + 1);
                _currentPacket.addHeader(key.trim(), value.trim());
              } else {
                _controller.addError(
                    new StateError('Skipping invalid buffer: "${headerLine}"'));
              }
            }
          }
          _headerBuffer = [];
        } else {
          _headerBuffer.add(_currentChar);
        }
      } else {
        assert(_currentPacket.contentLength > 0);
        _bodyBuffer.add(_currentChar);
        _contentLength++;
        if (_contentLength == _currentPacket.contentLength) {
          _currentPacket.content = new String.fromCharCodes(_bodyBuffer);
          _readingHeader = true;

          // Sink on the packet.
          _controller.sink.add(_currentPacket);

          // Clear the state.
          _bodyBuffer = [];
          _currentPacket = new Packet();
        }
      }
    }
  }
}
