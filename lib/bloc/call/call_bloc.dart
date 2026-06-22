import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_event.dart';
import 'call_state.dart';
import '../../repositories/call_repository.dart';
import '../../models/call_model.dart';
import '../../services/push_notification_service.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository callRepository;
  final PushNotificationService notificationService;

  CallBloc({
    required this.callRepository,
    required this.notificationService,
  }) : super(CallInitial()) {
    on<InitiateCallEvent>(_onInitiateCall);
    on<AcceptCallEvent>(_onAcceptCall);
    on<RejectCallEvent>(_onRejectCall);
    on<EndCallEvent>(_onEndCall);
  }

  Future<void> _onInitiateCall(InitiateCallEvent event, Emitter<CallState> emit) async {
    emit(CallLoading());
    try {
      final channelId = const Uuid().v4();
      final callModel = CallModel(
        callId: '',
        callerId: event.callerId,
        callerName: event.callerName,
        callerImage: event.callerImage,
        receiverId: event.receiverId,
        channelId: channelId,
        status: 'calling',
        createdAt: DateTime.now(),
      );
      
      final callId = await callRepository.initiateCall(callModel);
      
      
      final receiverDoc = await FirebaseFirestore.instance.collection('users').doc(event.receiverId).get();
      final receiverToken = receiverDoc.data()?['fcmToken'];
      
      if (receiverToken != null) {
        await notificationService.sendCallNotification(
          receiverToken: receiverToken,
          callId: callId,
          callerName: event.callerName,
          callerImage: event.callerImage,
        );
      }

      emit(CallInitiated(callId));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onAcceptCall(AcceptCallEvent event, Emitter<CallState> emit) async {
    await callRepository.updateCallStatus(event.callId, 'accepted');
    emit(CallAccepted());
  }

  Future<void> _onRejectCall(RejectCallEvent event, Emitter<CallState> emit) async {
    await callRepository.updateCallStatus(event.callId, 'rejected');
    await _sendEndNotificationToOtherUser(event.callId);
    emit(CallRejected());
  }

  Future<void> _onEndCall(EndCallEvent event, Emitter<CallState> emit) async {
    await callRepository.updateCallStatus(event.callId, 'ended');
    await _sendEndNotificationToOtherUser(event.callId);
    emit(CallEnded());
  }

  Future<void> _sendEndNotificationToOtherUser(String callId) async {
    try {
      final callDoc = await FirebaseFirestore.instance.collection('calls').doc(callId).get();
      if (!callDoc.exists) return;
      final data = callDoc.data()!;
      final callerId = data['callerId'];
      final receiverId = data['receiverId'];

      // Figure out who we are (we can use FirebaseAuth)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      final otherUserId = currentUser.uid == callerId ? receiverId : callerId;
      
      final otherUserDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      final otherUserToken = otherUserDoc.data()?['fcmToken'];
      if (otherUserToken != null) {
        await notificationService.sendCallEndedNotification(
          receiverToken: otherUserToken,
          callId: callId,
        );
      }
    } catch (e) {
      print("Error sending end notification: $e");
    }
  }
}
