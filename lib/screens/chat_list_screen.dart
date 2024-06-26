import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'contacts_screen.dart';
import '../bloc/chat_bloc.dart';
import 'package:collection/collection.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String _name = "Пользователь";
  String _avatarUrl = "";
  String _phone = "pochtamail.ru";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "Пользователь";
      _avatarUrl = prefs.getString('avatarUrl') ?? "";
      _phone = prefs.getString('phone') ?? "pochtamail.ru";
    });
  }

  Chat? _findChatByContact(Contact contact) {
    final state = BlocProvider.of<ChatBloc>(context).state;
    return state.chats.firstWhereOrNull((chat) => chat.name == contact.name && chat.avatarUrl == contact.avatarUrl);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Последние заметки'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _name,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 20),
              ),
              accountEmail: Text(
                _phone,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 18),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                child: _avatarUrl.isEmpty ? Icon(Icons.person, size: 40) : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Профиль',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ).then((_) => _loadProfile()); // Reload profile after returning
              },
            ),
            ListTile(
              leading: Icon(Icons.note),
              title: Text(
                'Последние заметки',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.note_add),
              title: Text(
                'Добавление заметок',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactsScreen(
                    findChatByContact: _findChatByContact,
                  )),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Настройки',
                style: TextStyle(fontSize: 18),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return state.chats.isEmpty
              ? Center(child: Text('Добавьте ЗАМЕТКУ!'))
              : ListView(
            children: state.chats.map((chat) {
              return ListTile(
                title: Text(
                  '- ${chat.name}',
                  style: TextStyle(fontSize: 18.0),

                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
