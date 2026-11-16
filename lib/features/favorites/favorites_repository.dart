import 'package:shared_preferences/shared_preferences.dart';

/// Guarda as cartas favoritas localmente, separadas por tipo.
abstract final class FavoritesRepository {
  static String _key({required bool isOrganization}) =>
      isOrganization ? 'favorites_org' : 'favorites_dia';

  static Future<Set<int>> load({required bool isOrganization}) async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key(isOrganization: isOrganization));
    if (values == null) return <int>{};
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<bool> toggle({
    required bool isOrganization,
    required int index,
  }) async {
    final favorites = await load(isOrganization: isOrganization);
    final added = !favorites.contains(index);
    if (added) {
      favorites.add(index);
    } else {
      favorites.remove(index);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key(isOrganization: isOrganization),
      favorites.map((value) => value.toString()).toList(),
    );
    return added;
  }
}
