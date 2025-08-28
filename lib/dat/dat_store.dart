
// Simples camada 'dat' (abstração local). Ajuste para seu back-end/DB real se necessário.
import 'package:shared_preferences/shared_preferences.dart';

class DatStore {
  static Future<void> setString(String key, String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, value);
  }
  static Future<String?> getString(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(key);
  }
  static Future<void> remove(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(key);
  }
}
