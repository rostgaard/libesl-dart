part of esl.test;

abstract class Response {
  static void detectsUsage () {
    const String buffer = '-USAGE: <uuid> [cause]';

    ESL.Response response = new ESL.Response.fromPacketBody(buffer);

    expect(response.status, equals(ESL.Response.USAGE));
  }

  static void detectsError () {
    const String buffer = '-ERR USER_NOT_REGISTERED';

    ESL.Response response = new ESL.Response.fromPacketBody(buffer);

    expect(response.status, equals(ESL.Response.ERROR));
  }

  static void detectsOK () {
    const String buffer = '+OK';

    ESL.Response response = new ESL.Response.fromPacketBody(buffer);

    expect(response.status, equals(ESL.Response.OK));
  }
}

