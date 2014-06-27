part of esl;

class Response {
  
  static int   count = 0; 
  
  static const String OK      = '+OK';
  static const String ERROR   = '-ERR';
  static const String UNKNOWN = '';

  final        String rawBody;
  
  Response.fromPacketBody (String this.rawBody) {
    count++;
  }
  
  String get status {
    String lastLine = this.rawBody.split('\n').last;
    
    if (lastLine.startsWith(OK)) {
      return OK;
    } else if (lastLine.startsWith(ERROR)) {
      return ERROR;
    } else {
      return UNKNOWN;
    }
  }
  
  String get channelUUID {
    String lastLine = this.rawBody.split('\n').last;
    
    if (lastLine.startsWith(OK)) {
      return lastLine.substring(OK.length, lastLine.length).trim();
    } else {
      throw new StateError ('Response does not carry channel information. Raw body: ${this.rawBody}');
    }
  }
}

