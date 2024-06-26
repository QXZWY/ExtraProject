import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "Пользователь";
  String _avatarUrl = "";
  String _phone = "pochtamail.ru";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
      _nameController.text = _name;
      _phoneController.text = _phone;
    });
  }

  _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name);
    prefs.setString('avatarUrl', _avatarUrl);
    prefs.setString('phone', _phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _showAvatarDialog();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                child: _avatarUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Имя'),
              controller: _nameController,
              onChanged: (value) {
                _name = value;
              },
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(labelText: 'Почта'),
              controller: _phoneController,
              onChanged: (value) {
                _phone = value;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProfile();
                Navigator.pop(context);
              },
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _avatarUrlController = TextEditingController();
        return AlertDialog(
          title: Text('Введите URL аватарки'),
          content: TextField(
            controller: _avatarUrlController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _avatarUrl = _avatarUrlController.text;
                });
                Navigator.pop(context);
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}
