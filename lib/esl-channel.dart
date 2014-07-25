part of esl;

/**
 * 'Enum' type representing channel states. 
 */
abstract class ChannelState {
  static const String NEW = "CS_NEW";
  static const String INIT = "CS_INIT";
  static const String ROUTING = "CS_ROUTING";
  static const String SOFT_EXECUTE = "CS_SOFT_EXECUTE";
  static const String EXECUTE = "CS_EXECUTE";
  static const String EXCHANGE_MEDIA = "CS_EXCHANGE_MEDIA";
  static const String PARK = "CS_PARK";
  static const String CONSUME_MEDIA = "CS_CONSUME_MEDIA";
  static const String HIBERNATE = "CS_HIBERNATE";
  static const String RESET = "CS_RESET";
  static const String HANGUP = "CS_HANGUP";
  static const String REPORTING = "CS_REPORTING";
  static const String DESTROY = "CS_DESTROY";
}

/**
 * Wrapper class for a channel. Provides easy access to various
 * channel information stored in a packet. 
 */
class Channel {
  
  static const String nullChannelID = null; 

  static final List<String >excludedFields = 
      ['Event-Name', 'Core-UUID', 'FreeSWITCH-Hostname', 'FreeSWITCH-IPv4',
       'FreeSWITCH-IPv6', 'Event-Date-Local', 'Event-Date-GMT', 
       'Event-Date-Timestamp', 'Event-Calling-File', 'Event-Calling-Function',
       'Event-Calling-Line-Number'];
  
  
  Map<String, String> _fields    = new Map<String, String>();
  Map<String, String> _variables = new Map<String, String>();
  String              get UUID  => this._fields['Unique-ID'];
  String              get state => this._fields['Channel-State'];
  
  /**
   * Extracts the relevant information from the packet and stores 
   * it in an internal map.
   */
  Channel.fromPacket (Packet packet) {
    packet.contentAsMap.forEach((key, value) {
      if (key.contains("^variable_")) {
        this._variables[key] = value;
      }
      else if (!excludedFields.contains(key)) {
        this._fields[key] = value;
      }
    });
  }
  
  /**
   * Returns a map _representation_ of the channel.
   */
  Map get asMap => 
      {}..addAll(this._fields)
        ..addAll(this._variables);
  
  /**
   * Two channel is equivalent, if their UUID's are the same
   * - regardless of state. 
   */
  @override
  bool operator == (Channel other) {
    return this.UUID.toLowerCase() == other.UUID.toLowerCase();
  }
   
  /**
   * Hashcode follows the convention from the [==] operator.
   */
  @override
  int get hashCode {
    return this.UUID.toLowerCase().hashCode;
  }
  
}

