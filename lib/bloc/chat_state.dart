part of 'chat_bloc.dart';

class ChatState extends Equatable {
  final List<Chat> chats;

  const ChatState({required this.chats});

  @override
  List<Object> get props => [chats];
}
class Chat extends Equatable {
  final String name;
  final String avatarUrl;
  final int messageCount;
  final String lastMessageTime;
  final List<Map<String, String>> messages;

  Chat({
    required this.name,
    required this.avatarUrl,
    this.messageCount = 0,
    this.lastMessageTime = '',
    this.messages = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      messageCount: json['messageCount'] ?? 0,
      lastMessageTime: json['lastMessageTime'] ?? '',
      messages: List<Map<String, String>>.from(json['messages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'messageCount': messageCount,
      'lastMessageTime': lastMessageTime,
      'messages': messages,
    };
  }

  @override
  List<Object> get props => [name, avatarUrl, messageCount, lastMessageTime, messages];
}