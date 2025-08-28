import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kThemeMode = 'theme_mode'; // 'light' | 'dark' | 'system'

  // ---------- AUTH ----------
  static Future<bool> getIsLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsLoggedIn) ?? false;
  }

  static Future<void> setIsLoggedIn(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kIsLoggedIn, value);
  }

  // ---------- THEME ----------
  static Future<String> getThemeMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kThemeMode) ?? 'system';
  }

  static Future<void> setThemeMode(String mode) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kThemeMode, mode); // 'light' | 'dark' | 'system'
  }
}
