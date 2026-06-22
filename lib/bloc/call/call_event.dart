abstract class CallEvent {}

class InitiateCallEvent extends CallEvent {
  final String receiverId;
  final String callerId;
  final String callerName;
  final String callerImage;
  InitiateCallEvent({
    required this.receiverId,
    required this.callerId,
    required this.callerName,
    required this.callerImage,
  });
}

class AcceptCallEvent extends CallEvent {
  final String callId;
  AcceptCallEvent(this.callId);
}

class RejectCallEvent extends CallEvent {
  final String callId;
  RejectCallEvent(this.callId);
}

class EndCallEvent extends CallEvent {
  final String callId;
  EndCallEvent(this.callId);
}
