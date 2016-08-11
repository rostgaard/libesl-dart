// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Packet transformer library.
library esl.packet_transformer;

import 'dart:async';
import 'dart:convert';

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
  final List<int> _headerBuffer = <int>[];
  final List<int> _bodyBuffer = <int>[];
  final Map<String, String> _headers = <String, String>{};
  bool _readingHeader = true;
  int _readBytes = 0;
  int _expectedContentLength = 0;
  int _currentChar;
  static const int _newLine = 10;

  ///Transform the incoming [stream]'s events into [Packet] object.
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

      /// Process a completed set of headers.
      void processHeaders() {
        if (_headers.containsKey('Content-Length')) {
          _readingHeader = false;
          _readBytes = 0;
          _expectedContentLength = int.parse(_headers['Content-Length']);
          _bodyBuffer.clear();
        } else {
          if (!_headers.containsKey('Content-Type') && _headers.isNotEmpty) {
            _controller.sink
                .addError(new StateError('Bad header received: $_headers'));
          }

          // Skip empty lines.
          else if (_headers.isNotEmpty) {
            _controller.sink.add(new Packet(
                new Map<String, String>.unmodifiable(_headers), const <int>[]));
          }
          _headers.clear();
        }
      }

      /// Read in bytes and process the bytes read as a packet header.
      void readAndProcessAsHeader() {
        if (_currentChar == _newLine) {
          // If we see two newlines in a sequence
          if (lastChar == _newLine) {
            processHeaders();
          } else {
            String headerLine = ASCII.decode(_headerBuffer, allowInvalid: true);

            // Ignore short lines.
            if (headerLine.length > 1) {
              int splitIndex = headerLine.indexOf(':');
              if (splitIndex > 0) {
                final String key = headerLine.substring(0, splitIndex);
                final String value = headerLine.substring(splitIndex + 1);
                _headers[key.trim()] = value.trim();
              } else {
                _controller.addError(
                    new StateError('Skipping invalid buffer: "$headerLine"'));
              }
            }
          }
          _headerBuffer.clear();
        } else {
          _headerBuffer.add(_currentChar);
        }
      }

      /// Reads and processes bytes as content.
      void readAndProcessAsContent() {
        _bodyBuffer.add(_currentChar);
        _readBytes++;

        // The amount of bytes read equals the expected content length which
        // means the we can now complete the packet we are reading.
        if (_readBytes == _expectedContentLength) {
          _readingHeader = true;

          // Sink on the packet.
          _controller.sink.add(new Packet(
              new Map<String, String>.unmodifiable(_headers),
              new List<int>.unmodifiable(_bodyBuffer)));

          // Empty the buffers for next packet.
          _bodyBuffer.clear();
          _headers.clear();
        }
      }

      // Packet parsing logic.
      if (_readingHeader) {
        readAndProcessAsHeader();
      } else {
        readAndProcessAsContent();
      }
    }
  }
}
