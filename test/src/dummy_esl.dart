library esl.test_support.dummy_esl;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logging/logging.dart';

const AsciiCodec _ascii = const AsciiCodec();

class _ClientConnection {
  final Socket socket;
  bool isAuthenticated = false;

  _ClientConnection(this.socket);
}

class IntCaster implements StreamTransformer<Uint8List, List<int>> {
  final StreamController<List<int>> _controller = new StreamController<List<int>>();

  @override
  Stream<List<int>> bind(Stream<Uint8List> stream) {
    stream.listen(_onData, onDone: _controller.close);
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    // TODO: implement cast
    return null;
  }

  void _onData(Uint8List bytes) {
    _controller.add(List<int>()..addAll(bytes));
  }

}

/// ESL dummy server that emulates the behaviour of a real FreeSWITCH ESL.
class DummyEsl {
  final Logger _log = new Logger('DummyEsl');
  final ServerSocket _socket;
  final String _password;
  final Set<_ClientConnection> _clients = new Set<_ClientConnection>();

  /// Default constructor.
  DummyEsl(this._socket, this._password) {
    _log.info('Server listening on ${_socket.address.address}:${_socket.port}');

    _socket.listen((Socket clientSocket) {
      _log.info('New client from ${clientSocket.address}');
      _ClientConnection client = new _ClientConnection(clientSocket);

      _clients.add(client);

      _authenticationChallenge(client);
    },
        onDone: () => _log.info(
            'Shutting down socket ${_socket.address.address}:${_socket.port}'));
  }

  void _send(_ClientConnection client, List<String> lines) {
    try {
      for (String line in lines) {
        client.socket.writeln(line);
      }
      client.socket.writeln();
    } catch (e) {
      _log.warning('Failed to send lines to client $client', e);
    }
  }

  ///
  Future<Null> _authenticationChallenge(_ClientConnection client) async {
    _log.finest('Sending authentication challenge');
    _send(client, <String>['Content-Type: auth/request']);

    client.socket
        .transform(IntCaster())
        .transform(_ascii.decoder)
        .transform(const LineSplitter())
        .where((String buffer) => buffer.isNotEmpty)
        .listen(
            (String buffer) {
              final List<String> parts = buffer.split(' ');
              final String command = parts.first;

              switch (command) {
                case 'auth':
                  final String password =
                      parts.length > 1 ? parts[1].trim() : '';

                  if (password != _password) {
                    _log.finest('password not ok');
                    _send(client, <String>[
                      'Content-Type: command/reply',
                      'Reply-Text: +ERROR'
                    ]);
                  } else {
                    _log.finest('password ok');
                    _send(client, <String>[
                      'Content-Type: command/reply',
                      'Reply-Text: +OK accepted'
                    ]);
                    client.isAuthenticated = true;
                  }
              }
            },
            onError: (dynamic e) => _log.warning('Client listener error', e),
            onDone: () {
              _log.info('Client ${client.socket.address.address} disconnected');
            });
  }

  /// Closes all client connections and server socket.
  Future<Null> close() async {
    for (_ClientConnection client in _clients) {
      try {
        await client.socket.close();
      } catch (e) {
        _log.warning('Failed to close socket', e);
      }
    }
    await _socket.close();
  }
}
