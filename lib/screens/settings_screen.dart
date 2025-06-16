// TODO Implement this library.// Path: lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bleau_todo_app/theme_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance ThemeModeManager
    final themeModeManager = Provider.of<ThemeModeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tampilan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Mode Gelap'),
            subtitle: const Text('Aktifkan mode gelap untuk tampilan aplikasi'),
            value: themeModeManager.themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              themeModeManager.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: Icon(themeModeManager.themeMode == ThemeMode.dark ? Icons.brightness_2 : Icons.brightness_high),
          ),
          // Anda bisa menambahkan pengaturan lain di sini
        ],
      ),
    );
  }
}