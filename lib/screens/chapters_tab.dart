import 'package:flutter/material.dart';
import '../data/chapters_data.dart';
import 'chapter_detail_screen.dart';
import 'subchapter_list_screen.dart';

class ChaptersTab extends StatelessWidget {
  const ChaptersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chapters.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.primary,
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
