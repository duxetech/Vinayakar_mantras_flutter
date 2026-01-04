import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _favoritesFilterKey = 'show_favorites_only_v1';

  static Future<bool> getShowFavoritesOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_favoritesFilterKey) ?? false;
  }

  static Future<void> setShowFavoritesOnly(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_favoritesFilterKey, value);
  }
}
