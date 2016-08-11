// Copyright (c) 2015, Kim Rostgaard Christensen. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Convenience library with pre-entered ESL constants.
library esl.constants;

import 'package:esl/esl.dart';

///'Enum' type representing channel states.
abstract class ChannelState {
  /// Channel is newly created.
  static const String newlyCreated = "CS_NEW";

  /// Channel has been initialized.
  static const String init = "CS_INIT";

  /// Channel is looking for an extension to execute.
  static const String routing = "CS_ROUTING";

  /// Channel is ready to execute from 3rd party control.
  static const String softExecute = "CS_SOFT_EXECUTE";

  /// Channel is executing its dialplan.
  static const String execute = "CS_EXECUTE";

  /// Channel is exchanging media with another channel.
  static const String exchangeMedia = "CS_EXCHANGE_MEDIA";

  /// Channel is accepting media awaiting commands.
  static const String park = "CS_PARK";

  /// Channel is consuming all media and dropping it.
  static const String consumeMedia = "CS_CONSUME_MEDIA";

  /// Channel is in a sleep state.
  static const String hibernate = "CS_HIBERNATE";

  /// Channel is in a reset state.
  static const String reset = "CS_RESET";

  /// Channel is flagged for hangup and ready to end.
  /// Media will now end, and no further call routing will occur.
  static const String hangup = "CS_HANGUP";

  /// The channel is already hung up, media is already down, and now
  /// it's time to do any sort of reporting processes such as CDR logging.
  static const String reporting = "CS_REPORTING";

  /// Channel is ready to be destroyed and out of the state machine.
  /// Memory pools are returned to the core and utilized memory from the
  /// channel is freed.
  static const String destroy = "CS_DESTROY";
}

/// "Enum" of event formats.
abstract class EventFormat {
  /// Plaintext event format
  static const String plain = "plain";

  /// JSON-encoded strings
  static const String json = "json";

  /// XML-encoded data
  static const String xml = "xml";
}

/// Different types of (known) command reply texts.
abstract class CommandReply {
  /// Command response `+OK` constant.
  static const String ok = '+OK';

  /// Command response `-ERR` constant.
  static const String error = '-ERR';

  /// Command response `-USAGE` constant.
  static const String usage = '-USAGE';

  /// Command reply for all other values.
  static const String unknown = '';
}

/// Packet content types.
abstract class ContentType {
  /// Content type `text/event-plain`.
  static const String textEventPlain = "text/event-plain";

  /// Content type `text/event-json`.
  static const String textEventJson = "text/event-json";

  /// Content type `text/event-xml`.
  static const String textEventXml = "text/event-xml";

  /// Content type `text/disconnect-notice`.
  static const String textDisconnectNotice = 'text/disconnect-notice';

  /// Content type `auth/request`.
  static const String authRequest = "auth/request";

  /// Content type `api/response`.
  static const String apiReponse = "api/response";

  /// Content type `command/reply`.
  static const String commandReply = "command/reply";

  /// List of content types that qualify as events. Useful for detmining if
  /// a [Packet] is an instance of an event.
  static const List<String> eventTypes = const <String>[
    textEventJson,
    textEventPlain,
    textEventXml
  ];

  /// List of content types that qualify as requests. Useful for detmining
  /// if a [Packet] is an instance of an request.
  static const List<String> requests = const <String>[authRequest];

  /// List of content types that qualify as response. Useful for detmining
  /// if a [Packet] is an instance of an response.
  static const List<String> responses = const <String>[apiReponse];

  /// List of content types that qualify as notices. Useful for detmining
  /// if a [Packet] is an instance of an notice.
  static const List<String> notices = const <String>[textDisconnectNotice];
}

/// Collection of event name constants.
abstract class EventType {
  // Channel events

  /// Event name constant for `CHANNEL_STATE`.
  static const String channelState = 'CHANNEL_STATE';

  /// Event name constant for `CHANNEL_ORIGINATE`.
  static const String channelOriginate = 'CHANNEL_ORIGINATE';

  /// Event name constant for `CHANNEL_CALLSTATE`.
  static const String channelCallState = 'CHANNEL_CALLSTATE';

  /// Event name constant for `CHANNEL_CREATE`.
  static const String channelCreate = 'CHANNEL_CREATE';

  /// Event name constant for `CHANNEL_DESTROY`.
  static const String channelDestroy = 'CHANNEL_DESTROY';

  /// Event name constant for `CHANNEL_ANSWER`.
  static const String channelAnswer = 'CHANNEL_ANSWER';

  /// Event name constant for `CHANNEL_HANGUP`.
  static const String channelHangup = 'CHANNEL_HANGUP';

  /// Event name constant for `CHANNEL_HANGUP_COMPLETE`.
  static const String channelHangupComplete = 'CHANNEL_HANGUP_COMPLETE';

  /// Event name constant for `CHANNEL_EXECUTE`.
  static const String channelExecute = 'CHANNEL_EXECUTE';

  /// Event name constant for `CHANNEL_EXECUTE_COMPLETE`.
  static const String channelExecuteComplete = 'CHANNEL_EXECUTE_COMPLETE';

  /// Event name constant for `CHANNEL_BRIDGE`.
  static const String channelBridge = 'CHANNEL_BRIDGE';

  /// Event name constant for `CHANNEL_UNBRIDGE`.
  static const String channelUnbridge = 'CHANNEL_UNBRIDGE';

  /// Event name constant for `CHANNEL_PROGRESS`.
  static const String channelProgress = 'CHANNEL_PROGRESS';

  /// Event name constant for `CHANNEL_PROGRESS_MEDIA`.
  static const String channelProgressMedia = 'CHANNEL_PROGRESS_MEDIA';

  /// Event name constant for `CHANNEL_OUTGOING`.
  static const String channelOutgoing = 'CHANNEL_OUTGOING';

  /// Event name constant for `CHANNEL_PARK`.
  static const String channelPark = 'CHANNEL_PARK';

  /// Event name constant for `CHANNEL_UNPARK`.
  static const String channelUnpark = 'CHANNEL_UNPARK';

  /// Event name constant for `CHANNEL_APPLICATION`.
  static const String channelApplication = 'CHANNEL_APPLICATION';

  /// Event name constant for `CHANNEL_HOLD`.
  static const String channelHold = 'CHANNEL_HOLD';

  /// Event name constant for `CHANNEL_UNHOLD`.
  static const String channelUnhold = 'CHANNEL_UNHOLD';

  /// Event name constant for `CHANNEL_UUID`.
  static const String channelUuid = 'CHANNEL_UUID';

  //System events

  /// Event name constant for `SHUTDOWN`.
  static const String shutdown = 'SHUTDOWN';

  /// Event name constant for `MODULE_LOAD`.
  static const String moduleLoad = 'MODULE_LOAD';

  /// Event name constant for `MODULE_UNLOAD`.
  static const String moduleUnload = 'MODULE_UNLOAD';

  /// Event name constant for `RELOADXML`.
  static const String reloadxml = 'RELOADXML';

  /// Event name constant for `NOTIFY`.
  static const String notify = 'NOTIFY';

  /// Event name constant for `SEND_MESSAGE`.
  static const String sendMessage = 'SEND_MESSAGE';

  /// Event name constant for `RECV_MESSAGE`.
  static const String recvMessage = 'RECV_MESSAGE';

  /// Event name constant for `REQUEST_PARAMS`.
  static const String requestParams = 'REQUEST_PARAMS';

  /// Event name constant for `CHANNEL_DATA`.
  static const String channelData = 'CHANNEL_DATA';

  /// Event name constant for `GENERAL`.
  static const String general = 'GENERAL';

  /// Event name constant for `COMMAND`.
  static const String command = 'COMMAND';

  /// Event name constant for `SESSION_HEARTBEAT`.
  static const String sessionHeartbeat = 'SESSION_HEARTBEAT';

  /// Event name constant for `CLIENT_DISCONNECTED`.
  static const String clientDisconnected = 'CLIENT_DISCONNECTED';

  /// Event name constant for `SERVER_DISCONNECTED`.
  static const String serverDisconnected = 'SERVER_DISCONNECTED';

  /// Event name constant for `RECV_INFO`.
  static const String recvInfo = 'RECV_INFO';

  /// Event name constant for `SEND_INFO`.
  static const String sendInfo = 'SEND_INFO';

  /// Event name constant for `CALL_SECURE`.
  static const String callSecure = 'CALL_SECURE';

  /// Event name constant for `NAT`.
  static const String nat = 'NAT';

  /// Event name constant for `RECORD_START`.
  static const String recordStart = 'RECORD_START';

  /// Event name constant for `RECORD_STOP`.
  static const String recordStop = 'RECORD_STOP';

  /// Event name constant for `PLAYBACK_START`.
  static const String playbackStart = 'PLAYBACK_START';

  /// Event name constant for `PLAYBACK_STOP`.
  static const String playbackStop = 'PLAYBACK_STOP';

  /// Event name constant for `CALL_UPDATE`.
  static const String callUpdate = 'CALL_UPDATE';

  //Other events

  /// Event name constant for `API`.
  static const String api = 'API';

  /// Event name constant for `BACKGROUND_JOB`.
  static const String backgroundJob = 'BACKGROUND_JOB';

  /// Event name constant for `CUSTOM`.
  static const String custom = 'CUSTOM';

  /// Event name constant for `RE_SCHEDULE`.
  static const String reSchedule = 'RE_SCHEDULE';

  /// Event name constant for `HEARTBEAT`.
  static const String heartbeat = 'HEARTBEAT';

  /// Event name constant for `DETECTED_TONE`.
  static const String detectedTone = 'DETECTED_TONE';

  /// Event name constant for `ALL`.
  static const String all = 'ALL';

  //Undocumented events.

  /// Event name constant for `LOG`.
  static const String log = 'LOG';

  /// Event name constant for `INBOUND_CHAN`.
  static const String inboundChan = 'INBOUND_CHAN';

  /// Event name constant for `OUTBOUND_CHAN`.
  static const String outboundChan = 'OUTBOUND_CHAN';

  /// Event name constant for `STARTUP`.
  static const String startup = 'STARTUP';

  /// Event name constant for `PUBLISH`.
  static const String publish = 'PUBLISH';

  /// Event name constant for `UNPUBLISH`.
  static const String unpublish = 'UNPUBLISH';

  /// Event name constant for `TALK`.
  static const String talk = 'TALK';

  /// Event name constant for `NOTALK`.
  static const String notalk = 'NOTALK';

  /// Event name constant for `SESSION_CRASH`.
  static const String sessionCrash = 'SESSION_CRASH';

  /// Event name constant for `DTMF`.
  static const String dtmf = 'DTMF';

  /// Event name constant for `MESSAGE`.
  static const String message = 'MESSAGE';

  /// Event name constant for `PRESENCE_IN`.
  static const String presenceIn = 'PRESENCE_IN';

  /// Event name constant for `PRESENCE_OUT`.
  static const String presenceOut = 'PRESENCE_OUT';

  /// Event name constant for `PRESENCE_PROBE`.
  static const String presenceProbe = 'PRESENCE_PROBE';

  /// Event name constant for `MESSAGE_WAITING`.
  static const String messageWating = 'MESSAGE_WAITING';

  /// Event name constant for `MESSAGE_QUERY`.
  static const String messageQuery = 'MESSAGE_QUERY';

  /// Event name constant for `ROSTER`.
  static const String roster = 'ROSTER';

  /// Event name constant for `RECV_RTCP_MESSAGE`.
  static const String recvRtcpMessage = 'RECV_RTCP_MESSAGE';

  /// Event name constant for `CODEC`.
  static const String codec = 'CODEC';

  /// Event name constant for `DETECTED_SPEECH`.
  static const String detectedSpeech = 'DETECTED_SPEECH';

  /// Event name constant for `PRIVATE_COMMAND`.
  static const String privateCommand = 'PRIVATE_COMMAND';

  /// Event name constant for `TRAP`.
  static const String trap = 'TRAP';

  /// Event name constant for `ADD_SCHEDULE`.
  static const String addSchedule = 'ADD_SCHEDULE';

  /// Event name constant for `DEL_SCHEDULE`.
  static const String delSchedule = 'DEL_SCHEDULE';

  /// Event name constant for `EXE_SCHEDULE`.
  static const String exeSchedule = 'EXE_SCHEDULE';
}

/// Collection of common ESL keys, provided for convenience.
abstract class Key {
  /// Key constant for `Event-Name`.
  static const String eventName = 'Event-Name';

  /// Key constant for `Core-UUID`.
  static const String coreUUID = 'Core-UUID';

  /// Key constant for `FreeSWITCH-Hostname`.
  static const String freeSWITCHHostname = 'FreeSWITCH-Hostname';

  /// Key constant for `FreeSWITCH-Switchname`.
  static const String freeSWITCHSwitchname = 'FreeSWITCH-Switchname';

  /// Key constant for `FreeSWITCH-IPv4`.
  static const String freeSWITCHIPv4 = 'FreeSWITCH-IPv4';

  /// Key constant for `FreeSWITCH-IPv6`.
  static const String freeSWITCHIPv6 = 'FreeSWITCH-IPv6';

  /// Key constant for `Event-Date-Local`.
  static const String eventDateLocal = 'Event-Date-Local';

  /// Key constant for `Event-Date-GMT`.
  static const String eventDateGMT = 'Event-Date-GMT';

  /// Key constant for `Event-Date-Timestamp`.
  static const String eventDateTimestamp = 'Event-Date-Timestamp';

  /// Key constant for `Event-Calling-File`.
  static const String eventCallingFile = 'Event-Calling-File';

  /// Key constant for `Event-Calling-Function`.
  static const String eventCallingFunction = 'Event-Calling-Function';

  /// Key constant for `Event-Calling-Line-Number`.
  static const String eventCallingLineNumber = 'Event-Calling-Line-Number';

  /// Key constant for `Event-Sequence`.
  static const String eventSequence = 'Event-Sequence';

  /// Key constant for `Channel-Call-State`.
  static const String channelCallState = 'Channel-Call-State';

  /// Key constant for `Channel-State`.
  static const String channelState = 'Channel-State';

  /// Key constant for `Channel-State-Number`.
  static const String channelStateNumber = 'Channel-State-Number';

  /// Key constant for `Channel-Name`. Value contains the channel name.
  static const String channelName = 'Channel-Name';

  /// Key constant for `Unique-ID`. Value contains the unique id
  /// of the channel.
  static const String uniqueID = 'Unique-ID';

  /// Key constant for `Call-Direction`. Value contains the call direction
  /// of the channel, which is a string literal whose value may be
  /// either `inbound` or `outbound`.
  static const String callDirection = 'Call-Direction';

  /// Key constant for `Presence-Call-Direction`.
  static const String presenceCallDirection = 'Presence-Call-Direction';

  /// Key constant for `Channel-HIT-Dialplan`.
  static const String channelHITDialplan = 'Channel-HIT-Dialplan';

  /// Key constant for `Channel-Call-UUID`.
  static const String channelCallUUID = 'Channel-Call-UUID';

  /// Key constant for `Answer-State`.
  static const String answerState = 'Answer-State';

  /// Key constant for `Hangup-Cause`.
  static const String hangupCause = 'Hangup-Cause';

  /// Key constant for `Channel-Read-Codec-Name`.
  static const String channelReadCodecName = 'Channel-Read-Codec-Name';

  /// Key constant for `Channel-Read-Codec-Rate`.
  static const String channelReadCodecRate = 'Channel-Read-Codec-Rate';

  /// Key constant for `Channel-Read-Codec-Bit-Rate`.
  static const String channelReadCodecBitRate = 'Channel-Read-Codec-Bit-Rate';

  /// Key constant for `Channel-Write-Codec-Name`.
  static const String channelWriteCodecName = 'Channel-Write-Codec-Name';

  /// Key constant for `Channel-Write-Codec-Rate`.
  static const String channelWriteCodecRate = 'Channel-Write-Codec-Rate';

  /// Key constant for `Channel-Write-Codec-Bit-Rate`.
  static const String channelWriteCodecBitRate = 'Channel-Write-Codec-Bit-Rate';

  /// Key constant for `Caller-Direction`.
  static const String callerDirection = 'Caller-Direction';

  /// Key constant for `Caller-Logical-Direction`.
  static const String callerLogicalDirection = 'Caller-Logical-Direction';

  /// Key constant for `Caller-Username`.
  static const String callerUsername = 'Caller-Username';

  /// Key constant for `Caller-Dialplan`.
  static const String callerDialplan = 'Caller-Dialplan';

  /// Key constant for `Caller-Caller-ID-Name`.
  static const String callerCallerIDName = 'Caller-Caller-ID-Name';

  /// Key constant for `Caller-Caller-ID-Number`.
  static const String callerCallerIDNumber = 'Caller-Caller-ID-Number';

  /// Key constant for `Caller-Caller-ID-Name`.
  static const String callerOrigCallerIDName = 'Caller-Orig-Caller-ID-Name';

  /// Key constant for `Caller-Orig-Caller-ID-Number`.
  static const String callerOrigCallerIDNumber = 'Caller-Orig-Caller-ID-Number';

  /// Key constant for `Caller-Network-Addr`.
  static const String callerNetworkAddr = 'Caller-Network-Addr';

  /// Key constant for `Caller-ANI`.
  static const String callerANI = 'Caller-ANI';

  /// Key constant for `Caller-Destination-Number`.
  static const String callerDestinationNumber = 'Caller-Destination-Number';

  /// Key constant for `Caller-Unique-ID`.
  static const String callerUniqueID = 'Caller-Unique-ID';

  /// Key constant for `Caller-Source`.
  static const String callerSource = 'Caller-Source';

  /// Key constant for `Caller-Transfer-Source`.
  static const String callerTransferSource = 'Caller-Transfer-Source';

  /// Key constant for `Caller-Context`.
  static const String callerContext = 'Caller-Context';

  /// Key constant for `Caller-RDNIS`.
  static const String callerRDNIS = 'Caller-RDNIS';

  /// Key constant for `Caller-Channel-Name`.
  static const String callerChannelName = 'Caller-Channel-Name';

  /// Key constant for `Caller-Profile-Index`.
  static const String callerProfileIndex = 'Caller-Profile-Index';

  /// Key constant for `Caller-Profile-Created-Time`.
  static const String callerProfileCreatedTime = 'Caller-Profile-Created-Time';

  /// Key constant for `Caller-Channel-Created-Time`.
  static const String callerChannelCreatedTime = 'Caller-Channel-Created-Time';

  /// Key constant for `Caller-Channel-Answered-Time`.
  static const String callerChannelAnsweredTime =
      'Caller-Channel-Answered-Time';

  /// Key constant for `Caller-Channel-Progress-Time`.
  static const String callerChannelProgressTime =
      'Caller-Channel-Progress-Time';

  /// Key constant for `Caller-Channel-Progress-Media-Time`.
  static const String callerChannelProgressMediaTime =
      'Caller-Channel-Progress-Media-Time';

  /// Key constant for `Caller-Channel-Hangup-Time`.
  static const String callerChannelHangupTime = 'Caller-Channel-Hangup-Time';

  /// Key constant for `Caller-Channel-Transfer-Time`.
  static const String callerChannelTransferTime =
      'Caller-Channel-Transfer-Time';

  /// Key constant for `Caller-Channel-Resurrect-Time`.
  static const String callerChannelResurrectTime =
      'Caller-Channel-Resurrect-Time';

  /// Key constant for `Caller-Channel-Bridged-Time`.
  static const String callerChannelBridgedTime = 'Caller-Channel-Bridged-Time';

  /// Key constant for `Caller-Channel-Last-Hold`.
  static const String callerChannelLastHold = 'Caller-Channel-Last-Hold';

  /// Key constant for `Caller-Channel-Hold-Accum`.
  static const String callerChannelHoldAccum = 'Caller-Channel-Hold-Accum';

  /// Key constant for `Caller-Screen-Bit`.
  static const String callerScreenBit = 'Caller-Screen-Bit';

  /// Key constant for `Caller-Privacy-Hide-Name`.
  static const String callerPrivacyHideName = 'Caller-Privacy-Hide-Name';

  /// Key constant for `Caller-Privacy-Hide-Number`.
  static const String callerPrivacyHideNumber = 'Caller-Privacy-Hide-Number';

  /// Key constant for ``Application.
  static const String application = 'Application';

  /// Key constant for `Application-Data`.
  static const String applicationData = 'Application-Data';

  /// Key constant for `Other-Type`.
  static const String otherType = 'Other-Type';

  /// Key constant for `Other-Leg-Direction`.
  static const String otherLegDirection = 'Other-Leg-Direction';

  /// Key constant for `Other-Leg-Logical-Direction`.
  static const String otherLegLogicalDirection = 'Other-Leg-Logical-Direction';

  /// Key constant for `Other-Leg-Username`.
  static const String otherLegUsername = 'Other-Leg-Username';

  /// Key constant for `Other-Leg-Dialplan`.
  static const String otherLegDialplan = 'Other-Leg-Dialplan';

  /// Key constant for `Other-Leg-Caller-ID-Name`.
  static const String otherLegCallerIDName = 'Other-Leg-Caller-ID-Name';

  /// Key constant for `Other-Leg-Caller-ID-Number`.
  static const String otherLegCallerIDNumber = 'Other-Leg-Caller-ID-Number';

  /// Key constant for `Other-Leg-Orig-Caller-ID-Name`.
  static const String otherLegOrigCallerIDName =
      'Other-Leg-Orig-Caller-ID-Name';

  /// Key constant for `Other-Leg-Orig-Caller-ID-Number`.
  static const String otherLegOrigCallerIDNumber =
      'Other-Leg-Orig-Caller-ID-Number';

  /// Key constant for `Other-Leg-Callee-ID-Name`.
  static const String otherLegCalleeIDName = 'Other-Leg-Callee-ID-Name';

  /// Key constant for `Other-Leg-Callee-ID-Number`.
  static const String otherLegCalleeIDNumber = 'Other-Leg-Callee-ID-Number';

  /// Key constant for `Other-Leg-Network-Addr`.
  static const String otherLegNetworkAddr = 'Other-Leg-Network-Addr';

  /// Key constant for `Other-Leg-ANI`.
  static const String otherLegANI = 'Other-Leg-ANI';

  /// Key constant for `Other-Leg-Destination-Number`.
  static const String otherLegDestinationNumber =
      'Other-Leg-Destination-Number';

  /// Key constant for `Other-Leg-Unique-ID`.
  static const String otherLegUniqueID = 'Other-Leg-Unique-ID';

  /// Key constant for `Other-Leg-Source`.
  static const String otherLegSource = 'Other-Leg-Source';

  /// Key constant for `Other-Leg-Context`.
  static const String otherLegContext = 'Other-Leg-Context';

  /// Key constant for `Other-Leg-RDNIS`.
  static const String otherLegRDNIS = 'Other-Leg-RDNIS';

  /// Key constant for `Other-Leg-Channel-Name`.
  static const String otherLegChannelName = 'Other-Leg-Channel-Name';

  /// Key constant for `Other-Leg-Profile-Created-Time`.
  static const String otherLegProfileCreatedTime =
      'Other-Leg-Profile-Created-Time';

  /// Key constant for `Other-Leg-Channel-Created-Time`.
  static const String otherLegChannelCreatedTime =
      'Other-Leg-Channel-Created-Time';

  /// Key constant for `Other-Leg-Channel-Answered-Time`.
  static const String otherLegChannelAnsweredTime =
      'Other-Leg-Channel-Answered-Time';

  /// Key constant for `Other-Leg-Channel-Progress-Time`.
  static const String otherLegChannelProgressTime =
      'Other-Leg-Channel-Progress-Time';

  /// Key constant for `Other-Leg-Channel-Progress-Media-Time`.
  static const String otherLegChannelProgressMediaTime =
      'Other-Leg-Channel-Progress-Media-Time';

  /// Key constant for `Other-Leg-Channel-Hangup-Time`.
  static const String otherLegChannelHangupTime =
      'Other-Leg-Channel-Hangup-Time';

  /// Key constant for `Other-Leg-Channel-Transfer-Time`.
  static const String otherLegChannelTransferTime =
      'Other-Leg-Channel-Transfer-Time';

  /// Key constant for `Other-Leg-Channel-Resurrect-Time`.
  static const String otherLegChannelResurrectTime =
      'Other-Leg-Channel-Resurrect-Time';

  /// Key constant for `Other-Leg-Channel-Bridged-Time`.
  static const String otherLegChannelBridgedTime =
      'Other-Leg-Channel-Bridged-Time';

  /// Key constant for `Other-Leg-Channel-Hold-Accum`.
  static const String otherLegChannelHoldAccum = 'Other-Leg-Channel-Hold-Accum';

  /// Key constant for `Other-Leg-Channel-Last-Hold`.
  static const String otherLegChannelLastHold = 'Other-Leg-Channel-Last-Hold';

  /// Key constant for `Other-Leg-Screen-Bit`.
  static const String otherLegScreenBit = 'Other-Leg-Screen-Bit';

  /// Key constant for `Other-Leg-Privacy-Hide-Name`.
  static const String otherLegPrivacyHideName = 'Other-Leg-Privacy-Hide-Name';

  /// Key constant for `Other-Leg-Privacy-Hide-Number`.
  static const String otherLegPrivacyHideNumber =
      'Other-Leg-Privacy-Hide-Number';
}
