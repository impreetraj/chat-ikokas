import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_ikokas/bloc/chat/chat_event.dart';
import 'package:chat_ikokas/bloc/chat/chat_state.dart';
import 'package:chat_ikokas/repositories/chat_repository.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      await chatRepository.sendMessage(event.chatroomId, event.message);
      emit(ChatSuccess());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
