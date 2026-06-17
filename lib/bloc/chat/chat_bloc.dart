import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_ikokas/bloc/chat/chat_event.dart';
import 'package:chat_ikokas/bloc/chat/chat_state.dart';
import 'package:chat_ikokas/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_ikokas/services/push_notification_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      await chatRepository.sendMessage(event.chatroomId, event.message);

      // Send Push Notification
      try {
        final firestore = FirebaseFirestore.instance;
        
        // Get sender name
        final senderDoc = await firestore.collection('users').doc(event.message.senderId).get();
        final senderName = senderDoc.data()?['name'] ?? 'Someone';

        // Get receiver FCM token
        final receiverDoc = await firestore.collection('users').doc(event.message.receiverId).get();
        final receiverFCMToken = receiverDoc.data()?['fcmToken'];

        if (receiverFCMToken != null) {
          PushNotificationService().sendNotification(
            receiverToken: receiverFCMToken,
            title: "New Message from $senderName",
            body: event.message.message,
          );
        }
      } catch (e) {
        print("Error sending message push notification: $e");
      }

      emit(ChatSuccess());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
