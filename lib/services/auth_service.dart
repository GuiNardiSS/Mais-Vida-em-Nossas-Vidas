import 'prefs.dart';

class AuthService {
  static Future<bool> isLoggedIn() => Prefs.getIsLoggedIn();

  static Future<void> login() async {
    await Prefs.setIsLoggedIn(true);
  }

  static Future<void> logout() async {
    await Prefs.setIsLoggedIn(false);
  }
}
