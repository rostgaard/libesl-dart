part of esl.test;

abstract class Response {
  static void detectsUsage() {
    const String buffer = '-USAGE: <uuid> [cause]';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.usage));
  }

  static void detectsError() {
    const String buffer = '-ERR USER_NOT_REGISTERED';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.error));
  }

  static void detectsOK() {
    const String buffer = '+OK';

    esl.Response response = new esl.Response.fromPacketBody(buffer);

    expect(response.status, equals(esl.Response.ok));
  }
}
