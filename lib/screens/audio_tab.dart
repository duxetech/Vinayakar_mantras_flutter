import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/audio_data.dart';
import '../models/audio_song.dart';

class AudioTab extends StatefulWidget {
  const AudioTab({super.key});

  @override
  State<AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioSong? _currentSong;
  int _currentIndex = -1;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
        
        // Auto-play next song when current one completes
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }
      }
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  Future<void> _playSong(AudioSong song) async {
    try {
      final index = audioSongs.indexOf(song);
      if (_currentSong == song && _isPlaying) {
        await _audioPlayer.pause();
      } else if (_currentSong == song && !_isPlaying) {
        await _audioPlayer.play();
      } else {
        setState(() {
          _currentSong = song;
          _currentIndex = index;
        });
        await _audioPlayer.setAsset(song.assetPath);
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playNext() async {
    if (_currentIndex < audioSongs.length - 1) {
      await _playSong(audioSongs[_currentIndex + 1]);
    } else {
      // Loop back to first song
      await _playSong(audioSongs[0]);
    }
  }

  Future<void> _playPrevious() async {
    if (_currentIndex > 0) {
      await _playSong(audioSongs[_currentIndex - 1]);
    } else {
      // Loop to last song
      await _playSong(audioSongs[audioSongs.length - 1]);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Song List
        Expanded(
          child: ListView.builder(
            itemCount: audioSongs.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final song = audioSongs[index];
              final isCurrentSong = _currentSong == song;
              
              return Card(
                elevation: isCurrentSong ? 4 : 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                color: isCurrentSong
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentSong
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      isCurrentSong && _isPlaying
                          ? Icons.music_note
                          : Icons.audiotrack,
                      color: isCurrentSong
                          ? Colors.white
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    song.duration,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isCurrentSong && _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _playSong(song),
                  ),
                  onTap: () => _playSong(song),
                ),
              );
            },
          ),
        ),

        // Audio Player Controls
        if (_currentSong != null)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Song Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSong!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _isPlaying ? 'Playing' : 'Paused',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds.toDouble() > 0
                              ? _duration.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            _seekTo(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Control Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous Button
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: _playPrevious,
                      ),
                      // Rewind 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10),
                        iconSize: 36,
                        onPressed: () {
                          final newPosition = _position - const Duration(seconds: 10);
                          _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
                        },
                      ),
                      // Play/Pause
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          iconSize: 40,
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      // Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10),
                        iconSize: 36,
                        onPressed: () {
                          final newPosition = _position + const Duration(seconds: 10);
                          _seekTo(newPosition > _duration ? _duration : newPosition);
                        },
                      ),
                      // Next Button
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 40,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: _playNext,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
