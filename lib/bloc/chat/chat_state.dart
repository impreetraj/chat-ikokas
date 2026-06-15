import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {}


class ChatError extends ChatState {
  final String error;
  const ChatError(this.error);
  @override
  List<Object> get props => [error];
}
