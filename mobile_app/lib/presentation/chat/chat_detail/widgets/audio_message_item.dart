import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AudioMessageItem extends StatefulWidget {
  final String audioUrl;
  final Duration? duration;
  final bool isMe;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  const AudioMessageItem({
    super.key,
    required this.audioUrl,
    this.duration,
    required this.isMe,
    this.onLongPress,
    this.onDoubleTap,
  });

  @override
  State<AudioMessageItem> createState() => _AudioMessageItemState();
}

class _AudioMessageItemState extends State<AudioMessageItem>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _playButtonController;
  late AnimationController _waveAnimationController;
  Timer? _positionTimer;

  // Mock audio waveform data (sẽ thay bằng real data từ audio file)
  final List<double> _waveformData = [
    0.2, 0.5, 0.8, 0.3, 0.9, 0.1, 0.7, 0.4, 0.6, 0.2,
    0.8, 0.9, 0.3, 0.7, 0.5, 0.1, 0.6, 0.4, 0.8, 0.2,
    0.5, 0.7, 0.9, 0.1, 0.3, 0.6, 0.4, 0.8, 0.2, 0.5,
  ];

  @override
  void initState() {
    super.initState();
    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Set initial duration nếu có
    if (widget.duration != null) {
      _totalDuration = widget.duration!;
    } else {
      _totalDuration = const Duration(seconds: 30); // Default duration
    }
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _waveAnimationController.dispose();
    _positionTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isPlaying = !_isPlaying;
      _isLoading = false;
    });

    if (_isPlaying) {
      _playButtonController.forward();
      _waveAnimationController.repeat();
      _startPositionTimer();
    } else {
      _playButtonController.reverse();
      _waveAnimationController.stop();
      _stopPositionTimer();
    }
  }

  void _startPositionTimer() {
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentPosition < _totalDuration) {
        setState(() {
          _currentPosition += const Duration(milliseconds: 100);
        });
      } else {
        // Audio finished
        _stopPlayback();
      }
    });
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
      _currentPosition = Duration.zero;
    });
    _playButtonController.reverse();
    _waveAnimationController.stop();
    _stopPositionTimer();
  }

  void _onSeek(double position) {
    final newPosition = Duration(
      milliseconds: (position * _totalDuration.inMilliseconds).round(),
    );
    setState(() {
      _currentPosition = newPosition;
    });
    
    // TODO: Implement actual audio seeking
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause Button
            _buildPlayButton(),
            const SizedBox(width: 12),
            
            // Waveform và Duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waveform
                  _buildWaveform(),
                  const SizedBox(height: 8),
                  
                  // Duration info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_currentPosition),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isMe
                              ? Colors.white.withAlpha(204)
                              : Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                      Text(
                        _formatDuration(_totalDuration),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isMe
                              ? Colors.white.withAlpha(204)
                              : Theme.of(context).colorScheme.onSurface.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Download/Status icon
            const SizedBox(width: 8),
            Icon(
              Icons.download_done,
              size: 16,
              color: widget.isMe
                  ? Colors.white.withAlpha(179)
                  : Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.isMe
              ? Colors.white.withAlpha(51)
              : Theme.of(context).colorScheme.primary.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : AnimatedBuilder(
                animation: _playButtonController,
                builder: (context, child) {
                  return Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    size: 24,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildWaveform() {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final progress = localPosition.dx / box.size.width;
        _onSeek(progress.clamp(0.0, 1.0));
      },
      child: SizedBox(
        height: 32,
        child: Row(
          children: _waveformData.asMap().entries.map((entry) {
            final index = entry.key;
            final amplitude = entry.value;
            final progress = _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
            final barProgress = index / _waveformData.length;
            final isActive = barProgress <= progress;
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: AnimatedBuilder(
                  animation: _waveAnimationController,
                  builder: (context, child) {
                    double animatedAmplitude = amplitude;
                    if (_isPlaying && isActive) {
                      animatedAmplitude *= (0.8 + 0.2 * _waveAnimationController.value);
                    }
                    
                    return Container(
                      height: 32 * animatedAmplitude,
                      decoration: BoxDecoration(
                        color: isActive
                            ? (widget.isMe
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary)
                            : (widget.isMe
                                ? Colors.white.withAlpha(102)
                                : Theme.of(context).colorScheme.onSurface.withAlpha(102)),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 
