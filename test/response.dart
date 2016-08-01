part of esl.test;

/// Tests for the [esl.Response] class.
abstract class Response {
  /// Tests if a [esl.Response] parses correct status upon -USAGE response.
  static void detectsUsage() {
    const String buffer = '-USAGE: <uuid> [cause]';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.usage));
  }

  /// Tests if a [esl.Response] parses correct status upon -ERR response.
  static void detectsError() {
    const String buffer = '-ERR USER_NOT_REGISTERED';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.error));
  }

  /// Tests if a [esl.Response] parses correct status upon +OK response.
  static void detectsOK() {
    const String buffer = '+OK';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.ok));
  }
}
