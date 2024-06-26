import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: ListTile(
        title: Text('Тёмная тема'),
        trailing: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return Switch(
              value: state.isDarkMode,
              onChanged: (value) {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            );
          },
        ),
      ),
    );
  }
}
