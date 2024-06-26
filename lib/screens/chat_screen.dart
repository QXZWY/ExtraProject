import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  ChatScreen({required this.chat});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Chat _chat;
  late List<Map<String, String>> _messages;

  @override
  void initState() {
    super.initState();
    _chat = widget.chat;
    _messages = List<Map<String, String>>.from(_chat.messages);
  }

  _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'sender': 'user', 'text': _controller.text});
      });
      String userMessage = _controller.text;
      _controller.clear();

      await _fetchReply(userMessage);
      _updateChat();
    }
  }

  _fetchReply(String userMessage) async {
    final response = await http.get(Uri.parse('https://api.quotable.io/random?maxLength=100'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _messages.add({'sender': 'bot', 'text': data['content']});
      });
      _updateChat();
    } else {
      throw Exception('Failed to load reply message');
    }
  }

  _updateChat() {
    final now = DateTime.now();
    _chat = Chat(
      name: _chat.name,
      avatarUrl: _chat.avatarUrl,
      messageCount: _messages.length,
      lastMessageTime: '${now.hour}:${now.minute}',
      messages: _messages,
    );
    BlocProvider.of<ChatBloc>(context).add(UpdateChatEvent(chat: _chat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('\"${_chat.name}\"'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message['sender'] == 'user';
                final textColor = isUserMessage ? Colors.black : Colors.black;
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      _sendMessage();
                    },
                    decoration: InputDecoration(
                      hintText: 'Введите дополнительную информацию',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
