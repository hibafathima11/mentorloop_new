import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A video player that prevents seeking/skipping
/// Students must watch the video continuously without skipping
class NonSkippableVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Function()? onPlay;
  final Function()? onPause;

  const NonSkippableVideoPlayer({
    super.key,
    required this.controller,
    this.onPlay,
    this.onPause,
  });

  @override
  State<NonSkippableVideoPlayer> createState() =>
      _NonSkippableVideoPlayerState();
}

class _NonSkippableVideoPlayerState extends State<NonSkippableVideoPlayer> {
  Duration _lastWatchedPosition = Duration.zero;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPositionChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    if (!widget.controller.value.isInitialized) return;

    final currentPosition = widget.controller.value.position;

    // Prevent seeking forward - only allow watching up to current position + small buffer
    // Allow small buffer (2 seconds) for network delays
    final maxAllowedPosition = _lastWatchedPosition + const Duration(seconds: 2);

    if (currentPosition > maxAllowedPosition && !_isUserInteracting) {
      // User tried to skip - reset to last watched position
      widget.controller.seekTo(_lastWatchedPosition);
      _showSkipWarning();
    } else if (currentPosition > _lastWatchedPosition) {
      // Update last watched position if watching forward normally
      _lastWatchedPosition = currentPosition;
    }

    // Prevent seeking backward beyond last watched position
    if (currentPosition < _lastWatchedPosition - const Duration(seconds: 1)) {
      widget.controller.seekTo(_lastWatchedPosition);
    }
  }

  void _showSkipWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ Skipping is not allowed. Please watch the video continuously.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Disable double tap to seek
      onDoubleTap: () {
        // Do nothing - prevent default seek behavior
      },
      // Disable long press
      onLongPress: () {
        // Do nothing - prevent default seek behavior
      },
      child: Stack(
        children: [
          // Video player without controls
          VideoPlayer(widget.controller),
          // Overlay to prevent interaction with video controls
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Only allow play/pause toggle
                setState(() {
                  if (widget.controller.value.isPlaying) {
                    widget.controller.pause();
                    widget.onPause?.call();
                  } else {
                    widget.controller.play();
                    widget.onPlay?.call();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                // Show play/pause icon overlay
                child: Center(
                  child: AnimatedOpacity(
                    opacity: widget.controller.value.isPlaying ? 0.0 : 0.7,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

