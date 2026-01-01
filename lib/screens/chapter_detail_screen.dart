// Chapter Detail Screen with zoom support
import 'package:flutter/material.dart';

import '../models/chapter.dart';
import '../data/chapters_data.dart';

class ChapterDetailScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterDetailScreen({super.key, required this.chapter});

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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _loadContent();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      await loadChapterContent(widget.chapter);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading content: ${e.toString()}';
        });
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
        title: Text(widget.chapter.title),
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
              : GestureDetector(
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
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.chapter.content ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ),
                  ),
                ),
    );
  }
}
