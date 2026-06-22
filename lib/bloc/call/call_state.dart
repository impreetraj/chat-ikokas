abstract class CallState {}

class CallInitial extends CallState {}
class CallLoading extends CallState {}
class CallInitiated extends CallState {
  final String callId;
  CallInitiated(this.callId);
}
class CallAccepted extends CallState {}
class CallRejected extends CallState {}
class CallEnded extends CallState {}
class CallError extends CallState {
  final String message;
  CallError(this.message);
}
