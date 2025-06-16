// Path: lib/theme_manager.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default ke sistem
  static const String _themeModeKey = 'app_theme_mode';

  ThemeModeManager() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_themeModeKey);
    if (storedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == 'ThemeMode.$storedMode',
        orElse: () => ThemeMode.system, // Fallback jika nilai tidak valid
      );
    }
    notifyListeners();
  }

  Future<void> toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    await prefs.setString(_themeModeKey, _themeMode.name);
    notifyListeners();
  }

  // Metode untuk mengatur tema secara spesifik (opsional, tapi berguna)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return; // Tidak perlu update jika sama
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.name);
    notifyListeners();
  }
} 