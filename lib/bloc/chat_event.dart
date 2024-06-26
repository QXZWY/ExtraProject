part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class AddChatEvent extends ChatEvent {
  final Chat chat;

  AddChatEvent({required this.chat});

  @override
  List<Object> get props => [chat];
}

class UpdateChatEvent extends ChatEvent {
  final Chat chat;

  UpdateChatEvent({required this.chat});

  @override
  List<Object> get props => [chat];
}
