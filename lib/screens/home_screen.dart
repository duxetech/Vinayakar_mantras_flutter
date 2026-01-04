import 'package:flutter/material.dart';
import 'chapters_tab.dart';
import 'audio_tab.dart';
import 'favorites_tab.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final val = await SettingsService.getShowFavoritesOnly();
    if (mounted) setState(() => _showFavoritesOnly = val);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'விநாயகர் மந்திரங்கள்',
          style: TextStyle(
            color: Color.fromARGB(255, 7, 45, 76),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Vinayagar Mantras'),
                  content: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vinayagar Mantras',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'A comprehensive collection of Lord Ganesha mantras and devotional songs.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Features:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Sacred mantras in text format'),
                        Text('• Audio playback with controls'),
                        Text('• Text-to-speech in Tamil'),
                        Text('• Continuous audio playback'),
                        SizedBox(height: 16),
                        Text(
                          'Developed by Karthik, Chennai, karthikriches@gmail.com',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'May Lord Ganesha bless you with wisdom and remove all obstacles from your path.',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_stories),
              text: 'Chapters',
            ),
            Tab(
              icon: Icon(Icons.music_note),
              text: 'Audio',
            ),
            Tab(
              icon: Icon(Icons.favorite),
              text: 'Favorites',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ChaptersTab(),
          AudioTab(),
          const FavoritesTab(),
        ],
      ),
    );
  }
}
