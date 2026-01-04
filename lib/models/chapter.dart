class Subchapter {
  final String title;
  final int? startLine;
  final int? endLine;

  Subchapter({required this.title, this.startLine, this.endLine});
}

class Chapter {
  final String id;
  final String title;
  final String assetPath;
  String? content;
  final List<Subchapter>? subchapters;

  Chapter({
    required this.id,
    required this.title,
    required this.assetPath,
    this.content,
    this.subchapters,
  });
}
