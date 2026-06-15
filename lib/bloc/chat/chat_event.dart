import 'package:equatable/equatable.dart';
import 'package:chat_ikokas/models/message_model.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String chatroomId;
  final MessageModel message;

  const SendMessageEvent(this.chatroomId, this.message);

  @override
  List<Object> get props => [chatroomId, message];
}
