// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

library esl.test.packet_transformer;

import 'dart:io' as io;
import 'dart:async';
import 'package:test/test.dart';
import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';

Logger _log = new Logger('esl.test.packet_transformer');

main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);
  const String dumpfilePath = 'test/test_data';

  group('PacketTransformer', () {
    test('basic session', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/basic_session.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));

      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('call session plain', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/call_session_plain.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('event background job plain', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/event_background_job_plain.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('event re-scedule', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/event_re_scedule.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('call session - json format', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/session1_json.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('event channel hangup complete', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/event_channel_hangup_complete.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('call session 2 - json format', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/json_session.ok');
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('shutdown session', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/shutdown_session.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('event heartbeat', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/event_heartbeat.ok');
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('voicemail session', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/voicemail_session.ok');
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    test('benchmark', () async {
      final _PacketProcessResult res =
          await _processAllDumpFiles(dumpfilePath, repeat: 3);
      expect(res.packetCount, greaterThan(0));
      expect(res.runtime.inMicroseconds, greaterThan(0));
      expect(res.byteCount, greaterThan(0));
      expect(res.errors, isEmpty);
      _log.finest(summary(res));
    });

    // Failure scenarios
    //
    test('event content length mismatch (should fail)', () async {
      final _PacketProcessResult res = await _parseFile(dumpfilePath +
          '/event_channel_answer_content_length_mismatch.should_fail');
      expect(res.errors, isNotEmpty);
      _log.finest(summary(res));
    });

    test('event missing_header (should fail)', () async {
      final _PacketProcessResult res = await _parseFile(
          dumpfilePath + '/event_channel_destroy_missing_header.should_fail');
      expect(res.errors, isNotEmpty);
      _log.finest(summary(res));
    });

    test('event missing header - alternate (should fail)', () async {
      final _PacketProcessResult res = await _parseFile(
          dumpfilePath + '/event_channel_destroy_missing_header.should_fail');
      expect(res.errors, isNotEmpty);
      _log.finest(summary(res));
    });

    test('event channel create (should fail)', () async {
      final _PacketProcessResult res =
          await _parseFile(dumpfilePath + '/event_channel_create.should_fail');
      expect(res.errors, isNotEmpty);
      _log.finest(summary(res));
    });
  });
}

class _PacketProcessResult {
  io.File file;
  Duration runtime;
  int packetCount = 0;
  int byteCount = -1;
  List errors = [];

  _PacketProcessResult.empty();

  _PacketProcessResult(
      this.file, this.runtime, this.packetCount, this.byteCount, this.errors);

  @override
  String toString() => '${file}\tpackets:${packetCount}'
      '\tmsec:${runtime.inMilliseconds}'
      '\tbytes:${byteCount}'
      '\terrors:${errors.length}';
}

Future<_PacketProcessResult> _parseFile(String testfilePath) async {
  Stopwatch timer = new Stopwatch()..start();
  final io.File packetDump = new io.File(testfilePath);
  final Completer done = new Completer();

  List errors = [];
  int packetCount = 0;

  final Stream<esl.Packet> packetStream =
      packetDump.openRead().transform(new esl.PacketTransformer());

  packetStream.listen((_) {
    packetCount++;
  }, onDone: () => done.complete(), onError: errors.add);

  await done.future;

  return new _PacketProcessResult(packetDump, timer.elapsed, packetCount,
      await packetDump.length(), errors);
}

/// Processes all dump files found in [testDataPath] multiple times.
///
/// The times repeated is passed in the [repeat] argument, and defaults
/// to 3 times, if omitted.
Future<_PacketProcessResult> _processAllDumpFiles(String testDataPath,
    {int repeat: 3}) async {
  StreamController<_PacketProcessResult> resultStream =
      new StreamController<_PacketProcessResult>();
  int fileCount = 0;
  Completer<bool> testCompleter = new Completer<bool>();

  _PacketProcessResult sum = new _PacketProcessResult.empty()
    ..runtime = new Duration();

  void endRun() {
    if (sum.errors.isNotEmpty) {
      testCompleter.completeError(new StateError(sum.errors.toString()));
    } else {
      testCompleter.complete(true);
    }
  }

  new List.generate(repeat, (_) => null).forEach((_) =>
      new io.Directory(testDataPath)
          .list(recursive: false, followLinks: true)
          .listen((io.FileSystemEntity fse) {
        if (fse is io.File) {
          String filename = fse.path.replaceAll(testDataPath, '');
          String suffix = filename.split('.').last;

          fileCount++;
          _testFile(fse, resultStream, shouldFail: (suffix == 'should_fail'));
        }
      }));

  int seenTests = 0;
  resultStream.stream.listen((_PacketProcessResult res) {
    seenTests++;
    sum.packetCount += res.packetCount;
    sum.runtime += res.runtime;
    sum.byteCount += res.byteCount;
    sum.errors.addAll(res.errors);

    if (seenTests == fileCount) {
      resultStream.close();
    }
  }).onDone(endRun);

  await testCompleter.future;
  return sum;
}

Future<bool> packetTransformer() async {
  String testDataPath = 'test/test_data/';
  StreamController<_PacketProcessResult> resultStream =
      new StreamController<_PacketProcessResult>();
  int fileCount = 0;
  Completer<bool> testCompleter = new Completer<bool>();

  _PacketProcessResult sum = new _PacketProcessResult.empty()
    ..runtime = new Duration();

  void endRun() {
    if (sum.errors.isNotEmpty) {
      testCompleter.completeError(new StateError(sum.errors.toString()));
    } else {
      testCompleter.complete(true);
    }
  }

  new List.generate(3, (_) => null).forEach((_) =>
      new io.Directory(testDataPath)
          .list(recursive: false, followLinks: true)
          .listen((io.FileSystemEntity fse) {
        if (fse is io.File) {
          String filename = fse.path.replaceAll(testDataPath, '');
          String suffix = filename.split('.').last;

          fileCount++;
          _testFile(fse, resultStream, shouldFail: (suffix == 'should_fail'));
        }
      }));

  int seenTests = 0;
  resultStream.stream.listen((_PacketProcessResult res) {
    seenTests++;
    sum.packetCount += res.packetCount;
    sum.runtime += res.runtime;
    sum.byteCount += res.byteCount;
    sum.errors.addAll(res.errors);

    if (seenTests == fileCount) {
      resultStream.close();
    }
  }).onDone(endRun);

  return testCompleter.future;
}

String summary(_PacketProcessResult res) {
  final double mibPerSecond = res.byteCount / res.runtime.inMicroseconds;

  return 'processing speed: ${mibPerSecond.toStringAsFixed(2)}MiB/µs\n'
      'total packets:${res.packetCount}\n'
      'total running time (msec):${res.runtime.inMilliseconds}\n'
      'bytes processed:${res.byteCount}\n'
      'number of errors:${res.errors.length}\n'
      'errors:\n'
      '${res.errors.fold('', (buf, error) => buf + error.toString() + '\n')}';
}

///
///
Future<_PacketProcessResult> _testFile(
    io.File testFile, StreamController<_PacketProcessResult> resultStream,
    {bool shouldFail: false}) async {
  DateTime start = new DateTime.now();

  _PacketProcessResult res = new _PacketProcessResult.empty();
  testFile
      .openRead()
      .transform(new esl.PacketTransformer())
      .listen((esl.Packet packet) => res.packetCount++, onDone: () {
    res.runtime = new DateTime.now().difference(start);
    testFile.length().then((int length) {
      res.byteCount = length;
      res.file = testFile;
      resultStream.add(res);
    });

    if (shouldFail) {
      if (res.errors.isEmpty) {
        res.errors.add(new StateError('Expected failure! ${testFile}'));
      } else {
        res.errors = [];
      }
    } else if (res.errors.isNotEmpty) {
      print(testFile);
      print(res.errors);
    }
  })..onError((error) => res.errors.add(error));

  await testFile.length();

  return res;
}
