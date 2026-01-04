// Chapter Detail Screen with zoom support and TTS
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/chapter.dart';
import '../data/chapters_data.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Chapter chapter;
  final Subchapter? initialSubchapter;
  const ChapterDetailScreen({super.key, required this.chapter, this.initialSubchapter});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _errorMessage = '';

  // Zoom
  final ScrollController _scrollController = ScrollController();
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  Offset _doubleTapPosition = Offset.zero;

  // TTS
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isPaused = false;
  List<String> _chunks = [];
  List<GlobalKey> _chunkKeys = [];
  int _currentChunkIndex = 0;
  double _seekPosition = 0.0;
  // Track chunk offsets inside the original content for jump-to-subchapter
  final List<int> _chunkStarts = [];
  final List<int> _chunkEnds = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _initTts();
    _loadContent();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _isSpeaking = false;
    _animationController.dispose();
    _scrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ta-IN");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (_currentChunkIndex < _chunks.length - 1) {
        _currentChunkIndex++;
        _seekPosition = _currentChunkIndex / (_chunks.length - 1);
        if (mounted) setState(() {});
        _speakCurrentChunk();
      } else {
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _isPaused = false;
            _currentChunkIndex = 0;
            _seekPosition = 0.0;
          });
        }
      }
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _isPaused = false;
        });
      }
    });
  }

  String _sanitizeForTts(String text) {
    // Add pauses for punctuation and remove other symbols
    String sanitized = text
        .replaceAll('.', ', ') // Replace dot with pause
        .replaceAll(':', ', ') // Replace colon with pause
        .replaceAll(',', ', ') // Normalize comma with pause
        // Convert digit groups to spoken whole-number words in Tamil
        .replaceAllMapped(RegExp(r'\d+'), (m) => _numberToTamilWords(m.group(0)!))
        .replaceAll(RegExp(r'[;!?।॥]'), ', ') // Replace other punctuation with pause
        .replaceAll(RegExp(r'[\u00B2\u00B3\u2070-\u209F]'), '') // Remove superscripts/subscripts
        .replaceAll(RegExp(r'[²³⁰¹⁴⁵⁶⁷⁸⁹]'), '') // Remove common superscripts
        .replaceAll(RegExp(r'[₀₁₂₃₄₅₆₇₈₉]'), '') // Remove subscripts
        .replaceAll(RegExp(r'[\[\]\(\)\{\}]'), '') // Remove brackets
        .replaceAll(RegExp(r'[*#@&%$+=/<>|\\~`^_]'), '') // Remove special symbols
        .replaceAll(RegExp(r'[-−–—]'), '') // Remove dashes and hyphens
        .replaceAll(RegExp(r'[™®©§¶†‡]'), '') // Remove trademark, copyright, etc
        .replaceAll(RegExp(r'[""''«»‹›]'), '') // Remove quotes
        .replaceAll('"', '') // Remove double quotes
        .replaceAll("'", '') // Remove single quotes
        .replaceAll(RegExp(r'[…·•]'), '') // Remove ellipsis, bullets
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
    return sanitized;
  }

  // Convert integer numeric string (no decimals) into English words.
  // Handles up to trillions; keeps implementation simple and dependency-free.
  String _numberToWords(String digits) {
    try {
      final n = int.parse(digits);
      if (n == 0) return ' zero';

      String helper(int num) {
        const below20 = [
          '', ' one', ' two', ' three', ' four', ' five', ' six', ' seven', ' eight', ' nine', ' ten', ' eleven', ' twelve', ' thirteen', ' fourteen', ' fifteen', ' sixteen', ' seventeen', ' eighteen', ' nineteen'
        ];
        const tens = ['', '', ' twenty', ' thirty', ' forty', ' fifty', ' sixty', ' seventy', ' eighty', ' ninety'];

        if (num < 20) return below20[num];
        if (num < 100) return tens[num ~/ 10] + (num % 10 != 0 ? below20[num % 10] : '');
        if (num < 1000) return helper(num ~/ 100) + ' hundred' + (num % 100 != 0 ? helper(num % 100) : '');
        return '';
      }

      final parts = <String>[];
      int remainder = n;

      final trillions = remainder ~/ 1000000000000;
      if (trillions > 0) {
        parts.add(helper(trillions) + ' trillion');
        remainder %= 1000000000000;
      }
      final billions = remainder ~/ 1000000000;
      if (billions > 0) {
        parts.add(helper(billions) + ' billion');
        remainder %= 1000000000;
      }
      final millions = remainder ~/ 1000000;
      if (millions > 0) {
        parts.add(helper(millions) + ' million');
        remainder %= 1000000;
      }
      final thousands = remainder ~/ 1000;
      if (thousands > 0) {
        parts.add(helper(thousands) + ' thousand');
        remainder %= 1000;
      }
      if (remainder > 0) {
        parts.add(helper(remainder));
      }

      return parts.join(', ');
    } catch (e) {
      return digits; // fallback to raw digits on parse error
    }
  }

  // Convert English number words produced by _numberToWords into Tamil equivalents.
  String _numberToTamilWords(String digits) {
    final eng = _numberToWords(digits).trim();
    if (eng.isEmpty) return digits;

    final map = <String, String>{
      'zero': 'பூஜ்ஜியம்',
      'one': 'ஒன்று',
      'two': 'இரண்டு',
      'three': 'மூன்று',
      'four': 'நான்கு',
      'five': 'ஐந்து',
      'six': 'ஆறு',
      'seven': 'ஏழு',
      'eight': 'எட்டு',
      'nine': 'ஒன்பது',
      'ten': 'பத்து',
      'eleven': 'பதினொன்று',
      'twelve': 'பன்னிரண்டு',
      'thirteen': 'பதினமூன்று',
      'fourteen': 'பதினாநாறு',
      'fifteen': 'பதினைந்து',
      'sixteen': 'பதினாறு',
      'seventeen': 'பதினேழு',
      'eighteen': 'பதினெட்டு',
      'nineteen': 'பத்தொன்பது',
      'twenty': 'இருபது',
      'thirty': 'முப்பது',
      'forty': 'நாற்பது',
      'fifty': 'அம்பது',
      'sixty': 'அறுபது',
      'seventy': 'எழுபது',
      'eighty': 'எண்பது',
      'ninety': 'தொண்ணூறு',
      'hundred': 'நூறு',
      'thousand': 'ஆயிரம்',
      'million': 'மில்லியன்',
      'billion': 'பில்லியன்',
      'trillion': 'டிரில்லியன்'
    };

    // Split on spaces and commas, translate tokens where possible
    final tokens = eng.split(RegExp(r'([,\s])+')).where((t) => t.isNotEmpty).toList();
    final out = <String>[];
    for (final t in tokens) {
      final lower = t.toLowerCase();
      if (lower == ',') {
        out.add(',');
      } else if (map.containsKey(lower)) {
        out.add(map[lower]!);
      } else {
        out.add(t); // fallback
      }
    }

    // Join tokens and normalize comma spacing
    final joined = out.join(' ').replaceAll(' , ', ', ');
    return ' ' + joined.trim();
  }

  void _prepareChunks() {
    if (widget.chapter.content == null || widget.chapter.content!.isEmpty) return;
    
    String content = widget.chapter.content!;
    
    // If a subchapter is selected, filter to show only that section
    if (widget.initialSubchapter != null) {
      final sub = widget.initialSubchapter!;
      final allLines = content.split('\n');

      if (sub.startLine != null) {
        // old numeric-range based slicing (1-based in data)
        final start = sub.startLine! - 1; // Convert to 0-based index
        final end = sub.endLine ?? allLines.length; // Use endLine if available
        final filteredLines = allLines.sublist(
          start.clamp(0, allLines.length),
          end.clamp(0, allLines.length),
        );
        content = filteredLines.join('\n');
      } else {
        // runtime heading detection: find the line that contains the subchapter title
        final headingPattern = RegExp(r'^\s*பகுதி\b', unicode: true);
        int headingLine = -1;
        for (int i = 0; i < allLines.length; i++) {
          final t = allLines[i].trim();
          if (t == sub.title || t.startsWith(sub.title)) {
            headingLine = i;
            break;
          }
        }

        if (headingLine == -1) {
          // fallback: search for the title anywhere in content
          final idx = content.indexOf(sub.title);
          if (idx != -1) {
            // find the line number containing idx
            int acc = 0;
            for (int i = 0; i < allLines.length; i++) {
              acc += allLines[i].length + 1; // +1 for '\n'
              if (acc > idx) {
                headingLine = i;
                break;
              }
            }
          }
        }

        if (headingLine != -1) {
          // find next heading line
          int nextHeading = allLines.length;
          for (int j = headingLine + 1; j < allLines.length; j++) {
            if (headingPattern.hasMatch(allLines[j].trim()) || allLines[j].trim().startsWith('பகுதி')) {
              nextHeading = j;
              break;
            }
          }

          final filteredLines = allLines.sublist(headingLine, nextHeading);
          content = filteredLines.join('\n');
        } else {
          // couldn't detect heading — leave full content
        }
      }
    }
    
    final terminators = RegExp(r'[.।॥\n]');

    // Collect raw chunks with offsets (preserve offsets in the original content)
    final List<Map<String, int>> rawMeta = [];
    final List<String> rawTexts = [];
    int start = 0;
    for (final match in terminators.allMatches(content)) {
      final raw = content.substring(start, match.end);
      if (raw.trim().isNotEmpty) {
        rawTexts.add(raw);
        rawMeta.add({'start': start, 'end': match.end});
      }
      start = match.end;
    }
    if (start < content.length) {
      final raw = content.substring(start);
      if (raw.trim().isNotEmpty) {
        rawTexts.add(raw);
        rawMeta.add({'start': start, 'end': content.length});
      }
    }

    // Merge very short raw chunks to avoid choppy playback, and compute start/end offsets
    _chunks = [];
    _chunkStarts.clear();
    _chunkEnds.clear();
    _chunkKeys = [];

    String buffer = '';
    int bufferStart = -1;
    int bufferEnd = -1;
    for (int i = 0; i < rawTexts.length; i++) {
      final txt = rawTexts[i];
      final meta = rawMeta[i];
      if (buffer.isEmpty) {
        buffer = txt;
        bufferStart = meta['start']!;
        bufferEnd = meta['end']!;
      } else if (buffer.length < 50) {
        buffer += ' ' + txt.trim();
        bufferEnd = meta['end']!;
      } else {
        final merged = buffer.trim();
        _chunks.add(merged);
        _chunkStarts.add(bufferStart);
        _chunkEnds.add(bufferEnd);
        _chunkKeys.add(GlobalKey());

        buffer = txt;
        bufferStart = meta['start']!;
        bufferEnd = meta['end']!;
      }
    }
    if (buffer.isNotEmpty) {
      final merged = buffer.trim();
      _chunks.add(merged);
      _chunkStarts.add(bufferStart);
      _chunkEnds.add(bufferEnd);
      _chunkKeys.add(GlobalKey());
    }
  }

  void _onSubchapterSelected(Subchapter sub) {
    if (widget.chapter.content == null) return;
    final content = widget.chapter.content!;
    final pos = content.indexOf(sub.title);
    int targetIndex = -1;
    if (pos != -1) {
      for (int i = 0; i < _chunkStarts.length; i++) {
        final s = _chunkStarts[i];
        final e = _chunkEnds[i];
        if (pos >= s && pos < e) {
          targetIndex = i;
          break;
        }
      }
    }

    // Fallback: try to match the title inside chunk texts
    if (targetIndex == -1) {
      for (int i = 0; i < _chunks.length; i++) {
        if (_chunks[i].contains(sub.title)) {
          targetIndex = i;
          break;
        }
      }
    }

    if (targetIndex != -1) {
      _flutterTts.stop();
      _currentChunkIndex = targetIndex;
      _seekPosition = _chunks.isNotEmpty ? _currentChunkIndex / (_chunks.length - 1) : 0.0;
      setState(() {});
      _scrollToChunk(_currentChunkIndex);
      if (_isSpeaking && !_isPaused) {
        _speakCurrentChunk();
      }
    } else {
      // Couldn't find exact match — just scroll to top
      if (_chunkKeys.isNotEmpty) Scrollable.ensureVisible(_chunkKeys.first.currentContext!, duration: const Duration(milliseconds: 300));
    }
  }

  Future<void> _loadContent() async {
    try {
      await loadChapterContent(widget.chapter);
      _prepareChunks();
      if (mounted) setState(() => _isLoading = false);
      
      // Auto-jump to initialSubchapter if provided
      if (widget.initialSubchapter != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _onSubchapterSelected(widget.initialSubchapter!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading content: ${e.toString()}';
        });
      }
    }
  }

  void _speakCurrentChunk() async {
    if (_currentChunkIndex >= _chunks.length) return;
    
    final sanitized = _sanitizeForTts(_chunks[_currentChunkIndex]);
    await _flutterTts.speak(sanitized);
    
    // Auto-scroll to current chunk
    _scrollToChunk(_currentChunkIndex);
  }

  void _scrollToChunk(int index) {
    if (index >= _chunkKeys.length) return;
    final key = _chunkKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleSpeak() async {
    if (_isSpeaking) {
      if (_isPaused) {
        // Resume
        await _flutterTts.speak(_sanitizeForTts(_chunks[_currentChunkIndex]));
        setState(() => _isPaused = false);
      } else {
        // Pause
        await _flutterTts.pause();
        setState(() => _isPaused = true);
      }
    } else {
      // Start speaking
      setState(() {
        _isSpeaking = true;
        _isPaused = false;
        _currentChunkIndex = 0;
        _seekPosition = 0.0;
      });
      _speakCurrentChunk();
    }
  }

  void _nextChunk() {
    if (_currentChunkIndex < _chunks.length - 1) {
      _flutterTts.stop();
      _currentChunkIndex++;
      _seekPosition = _currentChunkIndex / (_chunks.length - 1);
      setState(() {});
      _speakCurrentChunk();
    }
  }

  void _prevChunk() {
    if (_currentChunkIndex > 0) {
      _flutterTts.stop();
      _currentChunkIndex--;
      _seekPosition = _currentChunkIndex / (_chunks.length - 1);
      setState(() {});
      _speakCurrentChunk();
    }
  }

  void _onSeekChanged(double value) {
    final newIndex = (value * (_chunks.length - 1)).round();
    if (newIndex != _currentChunkIndex) {
      _flutterTts.stop();
      _currentChunkIndex = newIndex;
      _seekPosition = value;
      setState(() {});
      if (_isSpeaking && !_isPaused) {
        _speakCurrentChunk();
      }
    }
  }

  void _handleDoubleTap() {
    final Matrix4 current = _transformationController.value;
    final double currentScale = current.getMaxScaleOnAxis();
    final double target = currentScale > 1.5 ? 1.0 : 2.0;

    final renderBox = context.findRenderObject() as RenderBox?;
    final focal = renderBox != null ? renderBox.globalToLocal(_doubleTapPosition) : _doubleTapPosition;

    final Matrix4 begin = _transformationController.value;
    final double tx = -focal.dx * (target - 1);
    final double ty = -focal.dy * (target - 1);
    final Matrix4 translation = Matrix4.translationValues(tx, ty, 0);
    final Matrix4 scaling = Matrix4.diagonal3Values(target, target, 1);
    final Matrix4 end = translation.multiplied(scaling);

    _animation = Matrix4Tween(begin: begin, end: end).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    _animationController.reset();
    _animationController.addListener(() {
      _transformationController.value = _animation!.value;
    });
    _animationController.forward().then((_) => _animationController.removeListener(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(widget.chapter.title)),
            if (widget.chapter.subchapters != null && widget.chapter.subchapters!.isNotEmpty)
              PopupMenuButton<Subchapter>(
                tooltip: 'Select Subchapter',
                icon: const Icon(Icons.list),
                onSelected: (s) => _onSubchapterSelected(s),
                itemBuilder: (context) => widget.chapter.subchapters!
                    .map((s) => PopupMenuItem<Subchapter>(value: s, child: Text(s.title)))
                    .toList(),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    GestureDetector(
                      onDoubleTapDown: (d) => _doubleTapPosition = d.localPosition,
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1.0,
                        maxScale: 3.0,
                        boundaryMargin: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: _isSpeaking ? 120 : 16,
                          ),
                          child: _buildHighlightedText(),
                        ),
                      ),
                    ),
                    // Seek bar and controls at bottom
                    if (_isSpeaking)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous),
                                    onPressed: _currentChunkIndex > 0 ? _prevChunk : null,
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _seekPosition,
                                      onChanged: _onSeekChanged,
                                      min: 0.0,
                                      max: 1.0,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next),
                                    onPressed: _currentChunkIndex < _chunks.length - 1 ? _nextChunk : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    // FAB above seek bar
                    if (_isSpeaking)
                      Positioned(
                        right: 16,
                        bottom: 80,
                        child: FloatingActionButton(
                          onPressed: _toggleSpeak,
                          child: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        ),
                      ),
                  ],
                ),
      floatingActionButton: !_isSpeaking
          ? FloatingActionButton.extended(
              onPressed: _toggleSpeak,
              icon: const Icon(Icons.volume_up),
              label: const Text('Speak'),
            )
          : null,
    );
  }

  Widget _buildHighlightedText() {
    if (_chunks.isEmpty) {
      return Text(
        widget.chapter.content ?? '',
        style: const TextStyle(fontSize: 16, height: 1.6),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _chunks.asMap().entries.map((entry) {
        final index = entry.key;
        final chunk = entry.value;
        final isCurrentChunk = _isSpeaking && index == _currentChunkIndex;
        
        return Container(
          key: _chunkKeys[index],
          decoration: BoxDecoration(
            color: isCurrentChunk ? Colors.yellow.withAlpha((0.3 * 255).round()) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: isCurrentChunk ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) : null,
          child: Text(
            chunk,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              fontWeight: isCurrentChunk ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}
