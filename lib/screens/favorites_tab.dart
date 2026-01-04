import 'package:flutter/material.dart';
import '../data/chapters_data.dart';
import '../models/chapter.dart';
import '../services/favorites_service.dart';
import 'chapter_detail_screen.dart';
import 'subchapter_list_screen.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.loadFavorites();
    if (mounted) setState(() => _favorites = favs);
  }

  @override
  Widget build(BuildContext context) {
    final items = chapters.where((c) => _favorites.contains(c.id)).toList();

    if (items.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final chapter = items[index];
        final isFav = _favorites.contains(chapter.id);
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isFav ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/icons/chapter_icon.png',
                  fit: BoxFit.contain,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              chapter.title,
              style: TextStyle(
                fontWeight: isFav ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: IconButton(
                    key: ValueKey(isFav),
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                    onPressed: () async {
                      if (isFav) {
                        await FavoritesService.removeFavorite(chapter.id);
                      } else {
                        await FavoritesService.addFavorite(chapter.id);
                      }
                      await _loadFavorites();
                    },
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            onTap: () {
              if (chapter.subchapters != null && chapter.subchapters!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubchapterListScreen(chapter: chapter),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterDetailScreen(chapter: chapter),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
