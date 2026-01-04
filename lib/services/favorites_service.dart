import 'package:shared_preferences/shared_preferences.dart';
import '../data/chapters_data.dart';

class FavoritesService {
  static const _key = 'chapter_favorites_v1';

  // Load favorites; migrate legacy index-based (`chapter_<index>`) or title-based entries where possible.
  static Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];

    final migrated = <String>{};

    for (final entry in list) {
      // If entry already matches a chapter.id, keep it
      final byId = chapters.where((c) => c.id == entry).toList();
      if (byId.isNotEmpty) {
        migrated.add(entry);
        continue;
      }

      // If entry is legacy 'chapter_<index>', map to corresponding chapter.id
      if (entry.startsWith('chapter_')) {
        final idx = int.tryParse(entry.replaceFirst('chapter_', ''));
        if (idx != null && idx >= 0 && idx < chapters.length) {
          migrated.add(chapters[idx].id);
          continue;
        }
      }

      // If it matches a chapter title, map to chapter.id
      final byTitle = chapters.where((c) => c.title == entry).toList();
      if (byTitle.isNotEmpty) {
        migrated.add(byTitle.first.id);
        continue;
      }

      // Unknown entry — preserve (so upgrade doesn't drop unknown values)
      migrated.add(entry);
    }

    // Persist migrated list if it differs
    final originalSet = list.toSet();
    if (!SetEquality().equals(originalSet, migrated)) {
      await saveFavorites(migrated);
    }

    return migrated;
  }

  static Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids.toList());
  }

  static Future<void> addFavorite(String id) async {
    final favs = await loadFavorites();
    favs.add(id);
    await saveFavorites(favs);
  }

  static Future<void> removeFavorite(String id) async {
    final favs = await loadFavorites();
    favs.remove(id);
    await saveFavorites(favs);
  }
}

// Helper for list equality check
class SetEquality {
  bool equals(Set a, Set b) {
    if (a.length != b.length) return false;
    for (var e in a) if (!b.contains(e)) return false;
    return true;
  }
}
