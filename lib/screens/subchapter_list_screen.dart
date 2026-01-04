import 'package:flutter/material.dart';
import '../models/chapter.dart';
import 'chapter_detail_screen.dart';

class SubchapterListScreen extends StatelessWidget {
  final Chapter chapter;

  const SubchapterListScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final subchapters = chapter.subchapters ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: subchapters.isEmpty
          ? const Center(
              child: Text('No subchapters available'),
            )
          : ListView.builder(
              itemCount: subchapters.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final subchapter = subchapters[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    title: Text(
                      subchapter.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChapterDetailScreen(
                            chapter: chapter,
                            initialSubchapter: subchapter,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
