import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinayagar_mantras/services/favorites_service.dart';

void main() {
  test('FavoritesService stores and retrieves ids', () async {
    SharedPreferences.setMockInitialValues({});

    await FavoritesService.saveFavorites({'a', 'b'});
    final favs = await FavoritesService.loadFavorites();
    expect(favs.contains('a'), isTrue);
    expect(favs.contains('b'), isTrue);

    await FavoritesService.addFavorite('c');
    final favs2 = await FavoritesService.loadFavorites();
    expect(favs2.contains('c'), isTrue);

    await FavoritesService.removeFavorite('a');
    final favs3 = await FavoritesService.loadFavorites();
    expect(favs3.contains('a'), isFalse);
  });
}
