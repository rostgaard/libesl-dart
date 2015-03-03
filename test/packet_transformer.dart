// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

part of esl.test;

class Result {
  IO.File     file        = null;
  Duration    runtime     = null;
  int         packetCount = 0;
  int         byteCount   =-1;
  List<Error> errors      = [];

  String toString () => '${file}\tpackets:${packetCount}'
                        '\tmsec:${runtime.inMilliseconds}'
                        '\tbytes:${byteCount}'
                        '\terrors:${errors.length}';
}

Future<bool> packet_transformer () {
  String testDataPath         = './test_data/';
  StreamController<Result> resultStream = new StreamController<Result>();
  int fileCount = 0;
  Completer<bool> testCompleter = new Completer<bool>();

//  testFile(new IO.File( './test_data/json_session.ok'), resultStream);
  Result sum = new Result()..runtime = new Duration();

  void endRun () {
    if (sum.errors.isNotEmpty) {
      testCompleter.completeError(new StateError(sum.errors.toString()));
    } else {
      testCompleter.complete(true);
    }
  }

  new List.generate(3, (_) => null).forEach((_) =>
  new IO.Directory(testDataPath).list(recursive : false, followLinks: true)
    .listen((IO.FileSystemEntity fse) {
      if (fse is IO.File) {
        String filename  = fse.path.replaceAll(testDataPath, '');
        String suffix    = filename.split('.').last;

        fileCount++;
        testFile(fse, resultStream, shouldFail : (suffix == 'should_fail'));
      }
  }));

  int seenTests = 0;
  resultStream.stream.listen((Result res) {
    seenTests++;
    sum.packetCount += res.packetCount;
    sum.runtime     += res.runtime;
    sum.byteCount   += res.byteCount;
    sum.errors.addAll(res.errors);

    if (seenTests == fileCount) {
      resultStream.close();
    }

  }).onDone(endRun);

  return testCompleter.future;
}


String summary (Result res) =>
   'processing speed: ${(res.byteCount~/res.runtime.inMilliseconds)/1000}MiB/s\n'
   'total packets:${res.packetCount}\n'
   'total running time (msec):${res.runtime.inMilliseconds}\n'
   'bytes processed:${res.byteCount}\n'
   'number of errors:${res.errors.length}\n'
   'errors:\n'
   '${res.errors.fold('', (buf, error) => buf + error.toString() + '\n')}';


void testFile (IO.File testFile, StreamController<Result> resultStream, {bool shouldFail : false}) {
  int packetCount = 0;
  DateTime start  = new DateTime.now();

  Result res = new Result();
  testFile.openRead()
    .transform(new ESL.PacketTransformer())
      .listen((ESL.Packet packet) => res.packetCount++, onDone: ()
         {
           res.runtime = new DateTime.now().difference(start);
           testFile.length().then((int length) {
             res.byteCount = length;
             res.file = testFile;
             resultStream.add(res);
           });

           if (shouldFail) {
             if(res.errors.isEmpty) {
                res.errors.add(new StateError('Expected failure! ${testFile}'));
             } else {
               res.errors = [];
             }
           } else if (res.errors.isNotEmpty){
             print (testFile);
             print (res.errors);

           }
         })
          ..onError((error) => res.errors.add(error));

  //TODO return the file length
}