part of esl;

/**
 * Class representing a reponse received from the FreeSWTICH event socket.
 */
class Response {

  /// String constants that map to responses.
  static const String OK = '+OK';
  static const String ERROR = '-ERR';
  static const String USAGE = '-USAGE';
  static const String UNKNOWN = '';

  final String rawBody;

  Response.fromPacketBody(String this.rawBody);

  /**
   * The status of the response. Can be either [OK], [ERROR] or [UNKNOWN].
   */
  String get status {
    String lastLine = this.rawBody.split('\n').last;

    if (lastLine.startsWith(OK)) {
      return OK;
    } else if (lastLine.startsWith(ERROR)) {
      return ERROR;
    } else if (lastLine.startsWith(USAGE)) {
      return USAGE;
    } else {
      return UNKNOWN;
    }
  }

  /**
   * Reponses may carry the UUID of a channel.
   */
  String get channelUUID {
    String lastLine = this.rawBody.split('\n').last;

    if (lastLine.startsWith(OK)) {
      return lastLine.substring(OK.length, lastLine.length).trim();
    } else {
      throw new StateError(
          'Response does not carry channel information. '
          'Raw body: ${this.rawBody}');
    }
  }

  /**
   * String representation of a Response for debug purposes or
   * manual processing.
   */
  @override
  String toString() {
    return this.rawBody;
  }
}
