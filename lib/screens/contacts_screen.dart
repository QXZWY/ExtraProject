import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'chat_screen.dart';
import '../bloc/chat_bloc.dart';

class ContactsScreen extends StatefulWidget {
  final Chat? Function(Contact) findChatByContact;

  ContactsScreen({required this.findChatByContact});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  _loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      List<dynamic> contactsList = jsonDecode(contactsJson);
      setState(() {
        _contacts = contactsList.map((item) => Contact.fromJson(item)).toList();
      });
    }
  }

  _saveContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> contactsList = _contacts.map((contact) => contact.toJson()).toList();
    prefs.setString('contacts', jsonEncode(contactsList));
  }

  String _generateRandomPhoneNumber() {
    Random random = Random();
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    String phoneNumber = '';
    for (int i = 0; i < 9; i++) {
      phoneNumber += chars[random.nextInt(chars.length)];
    }
    return phoneNumber + '@mail.ru';
  }

  void _showContactProfile(Contact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: contact.avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(contact.avatarUrl)
                    : null,
                child: contact.avatarUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
              ),
              SizedBox(height: 20),
              Text('Автор заметки: ${_generateRandomPhoneNumber()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _contacts.remove(contact);
                  _saveContacts();
                });
                Navigator.of(context).pop();
              },
              child: Text('Удалить'),
              style: TextButton.styleFrom(primary: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заметки'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContactScreen(onAdd: (contact) {
                  setState(() {
                    _contacts.add(contact);
                    _saveContacts();
                  });
                })),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(
                    contact.name,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: contact.avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(contact.avatarUrl)
                        : null,
                    child: contact.avatarUrl.isEmpty ? Icon(Icons.person, size: 30) : null,
                  ),
                  trailing: Wrap(
                    spacing: 8, // space between two icons
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Chat? foundChat = widget.findChatByContact(contact);
                          if (foundChat == null) {
                            Chat chat = Chat(name: contact.name, avatarUrl: contact.avatarUrl);
                            BlocProvider.of<ChatBloc>(context).add(AddChatEvent(chat: chat));
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
                          }
                          else{
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatScreen(chat: foundChat)));}
                          },
                        child: Text('Перейти в заметку'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _contacts.removeAt(index);
                            _saveContacts();
                          });
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showContactProfile(contact);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddContactScreen(onAdd: (contact) {
                    setState(() {
                      _contacts.add(contact);
                      _saveContacts();
                    });
                  })),
                );
              },
              child: Text('Добавить заметку', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddContactScreen extends StatefulWidget {
  final Function(Contact) onAdd;

  AddContactScreen({required this.onAdd});

  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  String _name = "";
  String _avatarUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить заметку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Название'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'URL'),
              onChanged: (value) {
                setState(() {
                  _avatarUrl = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_name.isNotEmpty) {
                  widget.onAdd(Contact(name: _name, avatarUrl: _avatarUrl));
                  Navigator.pop(context);
                }
              },
              child: Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String avatarUrl;

  Contact({required this.name, required this.avatarUrl});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }
}
