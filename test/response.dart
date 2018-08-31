part of esl.test;

/// Tests for the [esl.Response] class.
abstract class Response {
  /// Tests if a [esl.Response] parses correct status upon -USAGE response.
  static void detectsUsage() {
    const String buffer = '-USAGE: <uuid> [cause]';
    esl.Packet packet =
        new esl.Packet(<String, String>{}, ascii.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.usage));

    expect(response.isOk, isFalse);
    expect(response.isError, isFalse);
  }

  /// Tests if a [esl.Response] parses correct status upon -ERR response.
  static void detectsError() {
    const String buffer = '-ERR USER_NOT_REGISTERED';
    esl.Packet packet =
        new esl.Packet(<String, String>{}, ascii.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.error));

    expect(response.isOk, isFalse);
    expect(response.isError, isTrue);
  }

  /// Tests if a [esl.Response] parses correct status upon +OK response.
  static void detectsOK() {
    const String buffer = '+OK [Success]';
    esl.Packet packet =
        new esl.Packet(<String, String>{}, ascii.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.ok));
    expect(response.isOk, isTrue);
    expect(response.isError, isFalse);
  }
}
