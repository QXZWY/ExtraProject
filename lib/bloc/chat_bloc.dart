import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState(chats: [])) {
    on<AddChatEvent>((event, emit) async {
      final newChats = List<Chat>.from(state.chats)..add(event.chat);
      emit(ChatState(chats: newChats));
      await _saveChats(newChats);
    });
    on<UpdateChatEvent>((event, emit) async {
      final updatedChats = state.chats.map((chat) {
        return chat.name == event.chat.name ? event.chat : chat;
      }).toList();
      emit(ChatState(chats: updatedChats));
      await _saveChats(updatedChats);
    });
    _loadChats();
  }

  _loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatsJson = prefs.getString('chats');
    if (chatsJson != null) {
      List<dynamic> chatList = jsonDecode(chatsJson);
      final chats = chatList.map((item) => Chat.fromJson(item)).toList();
      emit(ChatState(chats: chats));
    }
  }

  _saveChats(List<Chat> chats) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> chatList = chats.map((chat) => chat.toJson()).toList();
    prefs.setString('chats', jsonEncode(chatList));
  }
}
