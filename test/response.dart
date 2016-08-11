part of esl.test;

/// Tests for the [esl.Response] class.
abstract class Response {
  /// Tests if a [esl.Response] parses correct status upon -USAGE response.
  static void detectsUsage() {
    const String buffer = '-USAGE: <uuid> [cause]';
    esl.Packet packet = new esl.Packet({}, ASCII.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.usage));
  }

  /// Tests if a [esl.Response] parses correct status upon -ERR response.
  static void detectsError() {
    const String buffer = '-ERR USER_NOT_REGISTERED';
    esl.Packet packet = new esl.Packet({}, ASCII.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.error));
  }

  /// Tests if a [esl.Response] parses correct status upon +OK response.
  static void detectsOK() {
    const String buffer = '+OK';
    esl.Packet packet = new esl.Packet({}, ASCII.encode(buffer));

    esl.Response response = new esl.Response.fromPacket(packet);

    expect(response.status, equals(esl.CommandReply.ok));
  }
}
